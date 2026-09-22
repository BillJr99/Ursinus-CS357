# CS357 Course Development Container
# ----------------------------------
# One image that runs every CS357 lab: the Python libraries for retrieval,
# classical ML, NLP, and explainability, plus Node.js with promptfoo for the
# evaluation lab, opencode, the course coding agent, and herdr, the
# agent-aware terminal multiplexer. The ONE thing that
# stays OUTSIDE this container is Ollama:
# it runs natively on your host for model performance, and code inside the
# container reaches it at http://host.docker.internal:11434 -- exactly the
# host-bridge pattern from the "Docker from Zero" activity.
#
# Build it (from inside your work repo's .devcontainer/ folder):
#   docker compose build
# Enter it:
#   docker compose run --rm cs357
#
# The container sees ONLY the directory you mount at /workspace (your
# cloned GitHub work repo). Nothing else on your machine is visible to it.

FROM python:3.11-slim

LABEL org.opencontainers.image.title="CS357 course development environment" \
      org.opencontainers.image.description="Python 3.11 with the CS357 lab libraries (requests, chromadb, sentence-transformers, scikit-learn, spacy, shap, lime, flask, ...) plus Node.js 24 LTS, promptfoo, the opencode coding agent, the herdr agent multiplexer, and the gh GitHub CLI; talks to host Ollama via host.docker.internal" \
      org.opencontainers.image.authors="CS357 course staff" \
      org.opencontainers.image.url="https://www.billmongan.com/Ursinus-CS357/"

# System packages:
#   git      -- commit and push your work from inside the container
#   curl     -- probe the Ollama API and other HTTP endpoints
#   xz-utils -- unpack the Node.js release tarball installed further down
#   zip      -- package submissions
#
# Node.js is deliberately NOT in this list. Debian's `nodejs` package is too
# old for the course tools; see the Node.js section below.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        xz-utils \
        zip \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python packages, one per line, each tagged with the lab that uses it.
# (Comment lines inside a RUN continuation are stripped by the Dockerfile
# parser, so this reads as one pip install.)
RUN pip install --no-cache-dir \
        # requests -- every lab: HTTP calls to the Ollama API on the host
        requests \
        # chromadb -- RAG Knowledge Base Lab: the vector store for retrieval
        chromadb \
        # sentence-transformers -- RAG Knowledge Base Lab: embedding text for retrieval
        sentence-transformers \
        # scikit-learn -- Multi-Agent Patterns, rubric judge workshops: classical ML models and metrics
        scikit-learn \
        # numpy -- Multi-Agent Patterns, rubric judge workshops: the arrays underneath everything
        numpy \
        # spacy -- NLP pipelines (final projects and self-paced extensions)
        spacy \
        # shap -- model explanations (final projects and self-paced extensions)
        shap \
        # lime -- model explanations (final projects and self-paced extensions)
        lime \
        # matplotlib -- plots
        matplotlib \
        # pandas -- tabular data
        pandas \
        # flask -- Local Agent Lab Direction 4: a small web endpoint for your agent
        flask

# The small English model spacy needs, baked into the
# image so it works offline.
RUN python -m spacy download en_core_web_sm

# Node.js -- runs promptfoo (Judge Pipeline Workshop, Evaluation Workshop II) and opencode (the coding
# agent). Debian's own `nodejs` package will not do: bookworm ships Node 18.x
# and trixie ships 20.x, while promptfoo requires Node 22.22.0 or newer and
# refuses to start below it. So we install an official Node.js release
# straight from nodejs.org, pinned to an exact version and checked against the
# published SHASUMS256.txt *before* it is unpacked. That is the same
# download-then-verify discipline the python base image uses for CPython
# itself and the herdr installer uses for its binary: a tarball that does not
# match its checksum fails the build rather than landing in the image.  (This
# checks integrity against the manifest nodejs.org publishes over HTTPS.  The
# official Node images go one step further and verify that manifest's GPG
# signature against Node's release keys; that is the stronger guarantee, at the
# cost of a keyserver fetch that is a common source of flaky builds.)
#
# To move to a newer Node, bump NODE_VERSION; nothing else in this file
# changes. The trailing version checks make a bad install fail here, during
# the build, instead of failing for a student mid-lab.
ARG NODE_VERSION=24.21.0
RUN set -eux; \
        arch="$(dpkg --print-architecture)"; \
        case "$arch" in \
            amd64) narch='x64' ;; \
            arm64) narch='arm64' ;; \
            *) echo "unsupported architecture: $arch" >&2; exit 1 ;; \
        esac; \
        tarball="node-v${NODE_VERSION}-linux-${narch}.tar.xz"; \
        curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/${tarball}"; \
        curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt"; \
        grep " ${tarball}\$" SHASUMS256.txt | sha256sum -c -; \
        tar -xJf "${tarball}" -C /usr/local --strip-components=1 --no-same-owner; \
        rm -f "${tarball}" SHASUMS256.txt \
              /usr/local/CHANGELOG.md /usr/local/LICENSE /usr/local/README.md; \
        node --version; \
        npm --version

# promptfoo -- Judge Pipeline Workshop and Evaluation Workshop II: prompt/agent evaluation harness.
RUN npm install -g promptfoo

# opencode -- the course coding agent: OpenCode Studio Lab, the Coding Agents
# session, and Local Agent Lab Direction 5. It is baked into the image on
# purpose. `docker compose run --rm` deletes the container on exit and only
# /workspace is mounted, so an agent installed by hand into ~/.local/bin would
# have to be reinstalled every single session.
RUN npm install -g opencode-ai

# herdr -- the agent-aware terminal multiplexer (Agentic CLI Tools tutorial,
# Part IV). tmux keeps agents alive after you detach; herdr also shows which
# one is blocked, working, or done, which is what makes running several at
# once practical. The installer downloads a single release binary and verifies
# its SHA-256; HERDR_INSTALL_DIR puts it on the PATH for every user in the
# image rather than in root's ~/.local/bin, which `student` could not reach.
RUN curl -fsSL https://herdr.dev/install.sh | HERDR_INSTALL_DIR=/usr/local/bin sh

# gh -- the GitHub CLI. The Coding Agents session drives its whole loop through
# it (an issue becomes the task, a pull request becomes the attempt, a review
# comment becomes the next agent's instruction), Agents That Talk reuses those
# same commands as a message bus between two agents that never share a context
# window, and the Agent Skills tutorial assumes it is already on the PATH. It is
# baked in for the same reason opencode is: `docker compose run --rm` deletes the
# container on exit, so anything installed by hand is installed again tomorrow.
#
# As with Node above and herdr below, the release tarball is checked against the
# checksums GitHub publishes beside it before it is unpacked, so a corrupted or
# substituted download fails this build rather than failing in class.
#
# Two details worth knowing before you bump the version. gh names its builds
# linux_amd64 and linux_arm64, which are dpkg's own names, where Node called the
# same machine x64; copying the Node case statement verbatim gets you a 404. And
# this block sits near the end of the file deliberately: a change to the pip
# layers above invalidates everything beneath it, but a change to GH_VERSION here
# re-runs only these lines, so a rebuild for a newer gh takes seconds instead of
# downloading the ML libraries again.
ARG GH_VERSION=2.101.0
RUN set -eux; \
        arch="$(dpkg --print-architecture)"; \
        case "$arch" in \
            amd64|arm64) garch="$arch" ;; \
            *) echo "unsupported architecture: $arch" >&2; exit 1 ;; \
        esac; \
        dir="gh_${GH_VERSION}_linux_${garch}"; \
        tarball="${dir}.tar.gz"; \
        sums="gh_${GH_VERSION}_checksums.txt"; \
        base="https://github.com/cli/cli/releases/download/v${GH_VERSION}"; \
        curl -fsSLO "${base}/${tarball}"; \
        curl -fsSLO "${base}/${sums}"; \
        grep " ${tarball}\$" "${sums}" | sha256sum -c -; \
        tar -xzf "${tarball}" -C /usr/local --strip-components=1 --no-same-owner \
            "${dir}/bin/gh" "${dir}/share"; \
        rm -f "${tarball}" "${sums}"; \
        gh --version

# Code inside the container reaches the HOST's Ollama server here. This is
# the special DNS name Docker provides for "my host machine"; on Linux the
# compose file adds it explicitly via extra_hosts.
ENV OLLAMA_HOST=http://host.docker.internal:11434

# Work as a regular (non-root) user, like you would on your own machine.
RUN useradd --create-home --shell /bin/bash student
USER student

# All course work happens here; docker-compose.yml bind-mounts your cloned
# GitHub repo at this path.
WORKDIR /workspace

# Default to an interactive shell.
CMD ["bash"]
