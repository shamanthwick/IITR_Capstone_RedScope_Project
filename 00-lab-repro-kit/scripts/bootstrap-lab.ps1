param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$WorkDir = Join-Path $Root "assets/downloads"
$OvaDir = Join-Path $Root "assets/ova"
$MetaDir = Join-Path $Root "assets/metasploitable2"
$KaliOva = Join-Path $OvaDir "kali-linux-2026.1-virtualbox-amd64.ova"
$Kali7z  = Join-Path $WorkDir "kali-linux-2026.1-virtualbox-amd64.7z"
$MetaZip  = Join-Path $WorkDir "Metasploitable2-Linux.zip"

$KaliUrl = "https://kali.download/base-images/kali-2026.1/kali-linux-2026.1-virtualbox-amd64.7z"
# Inferred from the standard SourceForge release layout for Metasploitable 2.
$MetaUrl = "https://downloads.sourceforge.net/project/metasploitable/Metasploitable2/Metasploitable2-Linux.zip"

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutFile
    )

    if (Test-Path $OutFile) {
        return
    }

    Invoke-WebRequest -Uri $Url -OutFile $OutFile
}

function Ensure-KaliOva {
    Ensure-Directory $OvaDir
    Ensure-Directory $WorkDir

    if (Test-Path $KaliOva) {
        return $KaliOva
    }

    Download-File -Url $KaliUrl -OutFile $Kali7z

    Require-Command "7z"
    Push-Location $OvaDir
    try {
        & 7z x $Kali7z | Out-Host
    }
    finally {
        Pop-Location
    }

    $extracted = Get-ChildItem $OvaDir -Filter *.ova | Select-Object -First 1
    if (-not $extracted) {
        throw "Kali OVA was not extracted from $Kali7z."
    }

    if ($extracted.FullName -ne $KaliOva) {
        Move-Item -Force $extracted.FullName $KaliOva
    }

    return $KaliOva
}

function Ensure-MetasploitableZip {
    Ensure-Directory $WorkDir
    Ensure-Directory $MetaDir

    if (-not (Test-Path $MetaZip)) {
        Download-File -Url $MetaUrl -OutFile $MetaZip
    }

    $extractRoot = Join-Path $MetaDir "extracted"
    if (-not (Test-Path $extractRoot)) {
        Expand-Archive -Path $MetaZip -DestinationPath $extractRoot
    }

    $disk = Get-ChildItem $extractRoot -Recurse -Filter *.vmdk | Select-Object -First 1
    if (-not $disk) {
        throw "Metasploitable VMDK was not found after extracting $MetaZip."
    }

    return $disk.FullName
}

Require-Command "docker"
Require-Command "VBoxManage"

$VBoxManage = (Get-Command VBoxManage).Source

$kaliOvaPath = Ensure-KaliOva
$metaDiskPath = Ensure-MetasploitableZip

Write-Host "Ensuring VirtualBox NAT network exists..."
$existingNetworks = & $VBoxManage list natnets
if ($existingNetworks -notmatch "capstone-lab") {
    & $VBoxManage natnetwork add --netname capstone-lab --network "10.77.0.0/24" --enable | Out-Host
}
& $VBoxManage natnetwork start --netname capstone-lab | Out-Host

Write-Host "Importing Kali from OVA..."
if (& $VBoxManage list vms | Select-String '"RedScope-Kali"') {
    & $VBoxManage unregistervm "RedScope-Kali" --delete | Out-Null
}
& $VBoxManage import $kaliOvaPath --vsys 0 --vmname "RedScope-Kali" | Out-Host
& $VBoxManage modifyvm "RedScope-Kali" --memory 4096 --cpus 2 --nictype1 82540EM --nic1 natnetwork --nat-network1 capstone-lab | Out-Host

Write-Host "Creating Metasploitable VM from VMDK..."
if (& $VBoxManage list vms | Select-String '"RedScope-Metasploitable2"') {
    & $VBoxManage unregistervm "RedScope-Metasploitable2" --delete | Out-Null
}
& $VBoxManage createvm --name "RedScope-Metasploitable2" --ostype "Ubuntu_64" --register | Out-Host
& $VBoxManage modifyvm "RedScope-Metasploitable2" --memory 1024 --cpus 1 --nic1 natnetwork --nat-network1 capstone-lab | Out-Host
& $VBoxManage storagectl "RedScope-Metasploitable2" --name "SATA" --add sata --controller IntelAhci | Out-Host
& $VBoxManage storageattach "RedScope-Metasploitable2" --storagectl "SATA" --port 0 --device 0 --type hdd --medium $metaDiskPath | Out-Host

Write-Host "Starting Docker targets..."
Push-Location $Root
try {
    docker compose up -d
}
finally {
    Pop-Location
}

Write-Host "Starting VMs..."
& $VBoxManage startvm "RedScope-Kali" --type headless | Out-Host
& $VBoxManage startvm "RedScope-Metasploitable2" --type headless | Out-Host

Write-Host "Bootstrap complete."
