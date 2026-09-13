// NOTE: this file is the JS_RECOVERY_EOF heredoc body inside run-pi-ollama.sh,
// extracted so the rootless Dockerfile can COPY it.  Keep the two in sync;
// README.md has a one-line command that checks them.
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

export default function recovery(pi) {
  function record(ctx, kind, details) {
    try {
      const directory = path.join(ctx.cwd, ".pi", "recovery-events");
      fs.mkdirSync(directory, { recursive: true });
      const target = path.join(directory, `${Date.now()}-${crypto.randomUUID()}.json`);
      fs.writeFileSync(target, JSON.stringify({ kind, time: new Date().toISOString(),
        session: ctx.sessionManager.getSessionFile(), ...details }, null, 2) + "\n", { flag: "wx" });
    } catch (e) {
      console.error("[Pi recovery record]", e);
      console.error(e.stack);
    }
  }

  pi.on("turn_end", async (event, ctx) => {
    if (["length", "error", "aborted"].includes(event.message?.stopReason)) {
      record(ctx, "interrupted-turn", { stopReason: event.message.stopReason,
        error: event.message.errorMessage || null, turnIndex: event.turnIndex,
        toolResults: (event.toolResults || []).map(r => ({ toolCallId: r.toolCallId, isError: r.isError })) });
      ctx.ui.notify("Interrupted turn recorded. Check disk state before retrying. Use /smo-recover if context recovery fails.", "warning");
    }
  });

  pi.on("session_compact_failed", async (event, ctx) => {
    record(ctx, "compaction-failed", { reason: event.reason, error: event.errorMessage || null,
      aborted: event.aborted });
    if (!event.aborted) ctx.ui.notify("Compaction failed. /smo-recover starts a fresh session from RESUME.md.", "warning");
  });

  pi.registerCommand("smo-recover", {
    description: "Start a fresh session from the durable task checkpoint",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();
      const checkpoint = path.join(ctx.cwd, ".small-model-orchestrator", "RESUME.md");
      if (!fs.existsSync(checkpoint) || fs.statSync(checkpoint).size === 0) {
        ctx.ui.notify("No RESUME.md checkpoint. Inspect the saved session and reconstruct task state first.", "error");
        return;
      }
      const parentSession = ctx.sessionManager.getSessionFile();
      record(ctx, "fresh-session-requested", { checkpoint });
      await ctx.newSession({ parentSession, withSession: async (newContext) => {
        await newContext.sendUserMessage("Use small-model-orchestrator to resume the interrupted task. " +
          "Read .small-model-orchestrator/RESUME.md in bounded ranges, verify task identity and disk state, " +
          "and continue the next unverified action. Treat in-flight mutations as UNKNOWN until checked. " +
          "Preserve the contract and permissions. Do not reload the old transcript or replay successful mutations.");
      }});
    }
  });
}

