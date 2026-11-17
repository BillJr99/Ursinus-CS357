$ErrorActionPreference = 'Stop'
# Invoke FROM the disposable project directory, not the bundle unless intended.
$project = (Get-Location).ProviderPath
docker run --rm -it --init --platform linux/amd64 --cap-drop ALL --security-opt no-new-privileges --mount "type=bind,src=$project,dst=/workspace" cs357-herdr-opencode:nov17-candidate
if ($LASTEXITCODE -ne 0) { throw "Docker run failed ($LASTEXITCODE)" }
