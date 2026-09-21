"""ollama_client.py: the two functions every script in this course calls.

`load_config()` reads the JSON that holds every dial, so a change to the model,
the endpoint, the seed, or the logging level is a file edit rather than a code
edit.  `chat()` sends one request to Ollama's native chat endpoint and hands back
the reply text together with the raw response, because the token counts in that
response are what the trace table reports.

Config keys this module reads:

    ollama_url        the base URL of the Ollama server
    model             the model tag to call, for example "llama3.2"
    timeout_seconds   how long one request may take before it is abandoned
    log_level         DEBUG, INFO, WARNING, or ERROR

Everything else in config.json belongs to the caller.
"""

import json
import logging
import traceback

import requests

log = logging.getLogger("cs357.ollama")


def load_config(path="config.json"):
    """Read the JSON config, apply its logging level, and return it as a dict.

    The logging level is applied here rather than in every script, so one line
    in the file changes how talkative every program in the course is.
    """
    try:
        with open(path, encoding="utf-8") as f:
            cfg = json.load(f)
        logging.basicConfig(
            level=getattr(logging, str(cfg.get("log_level", "INFO")).upper(), logging.INFO),
            format="%(asctime)s %(levelname)s %(name)s %(message)s")
        log.debug("config loaded from %s: model=%s url=%s",
                  path, cfg.get("model"), cfg.get("ollama_url"))
        return cfg
    except FileNotFoundError as e:
        print(f"[ollama_client:load_config] no config file at {path}")
        print(f"[ollama_client:load_config] copy config.json from the starter "
              f"into this folder, or pass the path as the first argument")
        print(f"[ollama_client:load_config] {e}")
        traceback.print_exc()
        raise
    except json.JSONDecodeError as e:
        print(f"[ollama_client:load_config] {path} is not valid JSON: {e}")
        print(f"[ollama_client:load_config] a trailing comma after the last item "
              f"in a list or object is the usual cause")
        traceback.print_exc()
        raise
    except Exception as e:
        print(f"[ollama_client:load_config] {e}")
        traceback.print_exc()
        raise


def chat(cfg, user, system=None, temperature=0.0, seed=42, **extra):
    """Send one chat request to Ollama. Returns (text, raw_response_dict).

    The system prompt is sent as its own message rather than glued to the front
    of the user message, because that is the channel the model was trained to
    treat as standing policy.  Sampling options travel in the `options` object,
    which is where Ollama's native API expects them.
    """
    url = str(cfg.get("ollama_url", "http://localhost:11434")).rstrip("/") + "/api/chat"
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": user})
    options = {"temperature": temperature, "seed": seed}
    options.update(extra)
    payload = {"model": cfg.get("model", "llama3.2"),
               "messages": messages,
               "stream": False,
               "options": options}
    try:
        log.debug("POST %s model=%s options=%s", url, payload["model"], options)
        r = requests.post(url, json=payload,
                          timeout=cfg.get("timeout_seconds", 120))
        r.raise_for_status()
        data = r.json()
        text = (data.get("message") or {}).get("content", "")
        log.debug("reply %d chars, %s eval tokens", len(text), data.get("eval_count", 0))
        return text, data
    except requests.exceptions.ConnectionError as e:
        print(f"[ollama_client:chat] cannot reach Ollama at {url}")
        print(f"[ollama_client:chat] from a container, the host is "
              f"host.docker.internal, not localhost, and Ollama must have been "
              f"started with OLLAMA_HOST=0.0.0.0")
        print(f"[ollama_client:chat] {e}")
        traceback.print_exc()
        raise
    except requests.exceptions.Timeout as e:
        print(f"[ollama_client:chat] no reply within "
              f"{cfg.get('timeout_seconds', 120)}s from {url}")
        print(f"[ollama_client:chat] raise timeout_seconds in config.json, or "
              f"use a smaller model")
        print(f"[ollama_client:chat] {e}")
        traceback.print_exc()
        raise
    except Exception as e:
        print(f"[ollama_client:chat] {e}")
        traceback.print_exc()
        raise
