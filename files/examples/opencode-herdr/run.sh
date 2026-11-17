#!/bin/sh
set -eu
# Run this script FROM the disposable project directory you want to expose.
exec docker run --rm -it --init --platform linux/amd64 --cap-drop ALL --security-opt no-new-privileges --mount "type=bind,src=$(pwd -P),dst=/workspace" cs357-herdr-opencode:nov17-candidate
