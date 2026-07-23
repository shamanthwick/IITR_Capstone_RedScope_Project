param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$VBoxManage = Get-Command VBoxManage -ErrorAction SilentlyContinue
if (-not $VBoxManage) {
    $candidate = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
    if (Test-Path -LiteralPath $candidate) {
        $VBoxManage = [pscustomobject]@{ Source = $candidate }
    }
}

Push-Location $Root
try {
    docker compose up -d
}
finally {
    Pop-Location
}

if ($VBoxManage) {
    foreach ($vmName in @("Capstone-Kali", "Capstone-Metasploitable2")) {
        $running = & $VBoxManage.Source list runningvms
        if (-not ($running | Select-String -SimpleMatch "`"$vmName`"")) {
            & $VBoxManage.Source startvm $vmName --type headless | Out-Host
        }
    }
}
