param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

Push-Location $Root
try {
    docker ps
}
finally {
    Pop-Location
}

$VBoxManage = Get-Command VBoxManage -ErrorAction SilentlyContinue
if ($VBoxManage) {
    & $VBoxManage.Source list runningvms
}
