# syntax=docker/dockerfile:1
# Linux amd64 candidate; Herdr asset below is deliberately architecture-specific.
FROM node:22-bookworm-slim@sha256:e9f565d32859f0cbfb52125eafe8be39390f24dac302dc3cdf566e8ba3ab21ee
ARG CODER_UID=1000
ARG CODER_GID=1000
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git python3 ripgrep procps \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @opencode/cli@2.3.0 && npm cache clean --force
# Official manually downloaded release: avoids executing an unpinned remote installer.
RUN test "$(uname -m)" = x86_64 \
    && curl -fL --retry 3 https://github.com/herdrdev/herdr/releases/download/v0.9.5/herdr-linux-x86_64 -o /usr/local/bin/herdr \
    && printf '%s  %s\n' 14d9e8bc8b4a9e0118d77c32266f76d461f09b40342eb23752960bd89f59929d /usr/local/bin/herdr | sha256sum -c - \
    && chmod 755 /usr/local/bin/herdr
RUN groupmod -g "$CODER_GID" -n coder node \
    && usermod -u "$CODER_UID" -g coder -l coder -d /home/coder -m node \
    && mkdir -p /workspace /etc/opencode /home/coder/.config/opencode /home/coder/.config/herdr \
    && chown -R coder:coder /workspace /home/coder
ENV HOME=/home/coder SHELL=/bin/bash TERM=xterm-256color COLORTERM=truecolor
COPY opencode.json /etc/opencode/opencode.json
COPY herdr.toml /home/coder/.config/herdr/config.toml
COPY --chmod=755 demo-pane /usr/local/bin/demo-pane
USER coder
RUN herdr integration install opencode
WORKDIR /workspace
CMD ["herdr"]
