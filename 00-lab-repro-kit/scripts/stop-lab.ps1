param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$VBoxManageCommand = Get-Command VBoxManage -ErrorAction SilentlyContinue
if ($VBoxManageCommand) {
    $VBoxManage = $VBoxManageCommand.Source
}
else {
    $VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
}

Push-Location $Root
try {
    docker compose stop
} finally {
    Pop-Location
}

if (Test-Path $VBoxManage) {
    & $VBoxManage controlvm "Capstone-Kali" acpipowerbutton 2>$null | Out-Null
    & $VBoxManage controlvm "Capstone-Metasploitable2" acpipowerbutton 2>$null | Out-Null
}
