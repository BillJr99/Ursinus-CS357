# CS357 -- the pi coding agent, prebuilt, and never root at runtime
# ----------------------------------------------------------------
# This is the rootless companion to run-pi-ollama.sh.  That script is one
# self-contained file, which is its virtue, but it pays for that convenience by
# starting its container as root: installing apt packages into a stock node
# image requires root, and the script does that work on every launch.
#
# This image does the same privileged work ONCE, at build time, and then hands
# you an image that runs as an ordinary user forever after.  Nothing inside is
# ever root when you use run-pi-rootless.sh.
#
# Build it once, from this directory (same command in bash and PowerShell):
#   docker build -t course-pi-ollama .
# Then, from any project directory:
#   docker run --rm -it --add-host=host.docker.internal:host-gateway \
#     -v "$PWD:/workspace" -e PI_OLLAMA_MODEL=llama3.2 course-pi-ollama
#
# Ollama stays on your HOST, as everywhere else in this course.  The container
# reaches it at http://host.docker.internal:11434 -- the host-bridge pattern
# from the "Docker from Zero" tutorial.

FROM node:24-bookworm

LABEL org.opencontainers.image.title="CS357 pi coding agent (rootless)" \
      org.opencontainers.image.description="The pi coding agent with the small-model-orchestrator launcher, prebuilt so nothing runs as root at runtime; talks to host Ollama via host.docker.internal" \
      org.opencontainers.image.url="https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/FilesystemIsolation"

# System packages, installed as root at BUILD time -- the whole point of this file.
#   git            -- pi shows you diffs before it writes anything
#   python3        -- runs the launcher, and is what the agent tests against
#   python3-pytest -- the verifier the orchestrator skill expects to be able to call
#   ripgrep        -- fast bounded search, which is how the skill reads large files
#   ca-certificates-- TLS for the npm install below
# util-linux is deliberately ABSENT: the script needs setpriv to drop privileges,
# and this image never has privileges to drop.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        python3 \
        python3-pytest \
        ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Pin the agent exactly as the script does, so both routes run the same code.
# --ignore-scripts blocks package lifecycle hooks, which are arbitrary code that
# would otherwise execute as root during this build.
ARG PI_PACKAGE=@earendil-works/pi-coding-agent@0.85.1
RUN mkdir -p /opt/pi /opt/pi-launcher \
    && npm install --prefix /opt/pi --ignore-scripts --no-audit --no-fund "$PI_PACKAGE"

# The same launcher and recovery extension the script writes via heredoc.
COPY launcher.py /opt/pi-launcher/launcher.py
COPY recovery.mjs /opt/pi-launcher/recovery.mjs

# World-readable, because the UID that runs this image is not known at build
# time: run-pi-rootless.sh passes YOUR uid so bind-mounted files keep your
# ownership instead of coming back owned by root.
RUN chmod -R a+rX /opt/pi /opt/pi-launcher

ENV PATH="/opt/pi/node_modules/.bin:$PATH" \
    PI_BIN=/opt/pi/node_modules/.bin/pi \
    PI_WORKSPACE=/workspace

# HOME lives under /tmp, which is world-writable (mode 1777), so ANY uid you run
# this as has a writable home.  A fixed /home/agent would only work for one uid.
ENV HOME=/tmp/pi-home

# A sensible default if someone runs the image without --user.  Passing --user
# overrides this, which is exactly what the runner script does.
RUN useradd --create-home --shell /bin/bash agent
USER agent

WORKDIR /workspace
ENTRYPOINT ["python3", "/opt/pi-launcher/launcher.py"]
