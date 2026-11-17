$ErrorActionPreference = 'Stop'
# Docker Desktop must be in Linux-container mode. Candidate is amd64 only.
docker build --platform linux/amd64 -t cs357-herdr-opencode:nov17-candidate $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw "Docker build failed ($LASTEXITCODE)" }
