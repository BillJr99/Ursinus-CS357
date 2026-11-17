#!/bin/sh
set -eu
bundle=$(CDPATH= cd "$(dirname "$0")" && pwd)
docker build --platform linux/amd64 --build-arg "CODER_UID=$(id -u)" --build-arg "CODER_GID=$(id -g)" -t cs357-herdr-opencode:nov17-candidate "$bundle"
