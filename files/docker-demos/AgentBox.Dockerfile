FROM oven/bun:1.4.4-debian@sha256:93d5032fe06d163427822dc1598f420363759bb18155c9cc90eb1be05a64a19e
USER root
ARG TARGETARCH
ARG OMP_VERSION=18.18.1
ARG OPENCODE_VERSION=1.19.5
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends ca-certificates curl git unzip tar jq util-linux \
 && rm -rf /var/lib/apt/lists/*
RUN BUN_INSTALL=/opt/agents bun install -g "@oh-my-pi/pi-coding-agent@${OMP_VERSION}" \
 && ln -sfn /opt/agents/install/global/node_modules/@oh-my-pi/pi-coding-agent/dist/cli.js /usr/local/bin/omp \
 && chmod -R a+rX /opt/agents
RUN case "$TARGETARCH" in \
      amd64) arch=x64; sha=588310a336fa3b9df36b3f0225b26f679d453efaad0cf3d66c3651ef3ec1647a ;; \
      arm64) arch=arm64; sha=fae5be262d693b7c5e562856cc473e59e741772936db0c0600ac0d5ed5bd088b ;; \
      *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-$arch.tar.gz" -o /tmp/opencode.tar.gz \
 && printf '%s  %s\n' "$sha" /tmp/opencode.tar.gz | sha256sum -c - \
 && tar -xzf /tmp/opencode.tar.gz -C /usr/local/bin opencode \
 && chmod 755 /usr/local/bin/opencode \
 && rm /tmp/opencode.tar.gz
RUN case "$TARGETARCH" in \
      amd64) arch=x86_64; sha=14d9e8bc8b4a9e0118d77c32266f76d461f09b40342eb23752960bd89f59929d ;; \
      arm64) arch=aarch64; sha=17d7536f2da50859523680ef279dffcac8e4a235f4e46fe8da6c2ec44141897c ;; \
      *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/herdrdev/herdr/releases/download/v0.9.5/herdr-linux-$arch" -o /usr/local/bin/herdr \
 && printf '%s  %s\n' "$sha" /usr/local/bin/herdr | sha256sum -c - \
 && chmod 755 /usr/local/bin/herdr \
 && chmod 711 /home \
 && mkdir -p /workspace /opt/agents/seed
COPY opencode.json models.yml config.yml box-start /opt/agents/seed/
RUN chmod 755 /opt/agents/seed/box-start
USER bun
ENV HOME=/home/bun
WORKDIR /workspace
ENTRYPOINT ["/opt/agents/seed/box-start"]
CMD ["herdr"]
