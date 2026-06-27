param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

Push-Location $Root
try {
    docker compose up -d
}
finally {
    Pop-Location
}
