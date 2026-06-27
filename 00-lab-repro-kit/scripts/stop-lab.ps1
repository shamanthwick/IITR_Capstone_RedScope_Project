param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$VBoxManage = "D:\viertual box\VBoxManage.exe"
if (-not (Test-Path $VBoxManage)) {
    $VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
}

Push-Location $Root
try {
    docker compose stop
} finally {
    Pop-Location
}

if (Test-Path $VBoxManage) {
    & $VBoxManage controlvm "RedScope-Kali" acpipowerbutton 2>$null | Out-Null
    & $VBoxManage controlvm "RedScope-Metasploitable2" acpipowerbutton 2>$null | Out-Null
}
