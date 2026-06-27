param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

Push-Location $Root
try {
    docker ps
}
finally {
    Pop-Location
}
