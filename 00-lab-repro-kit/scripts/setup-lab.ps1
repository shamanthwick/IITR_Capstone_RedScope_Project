param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$ManifestPath = "",
    [string]$KaliOvaUrl = "",
    [string]$MetasploitableOvaUrl = "",
    [string]$JuiceShopTarUrl = "",
    [string]$DvwaTarUrl = "",
    [string]$Sha256SumsUrl = "",
    [switch]$ValidateOnly,
    [switch]$SkipHashCheck,
    [switch]$ReplaceExisting,
    [switch]$SkipVmStart,
    [switch]$SkipDockerStart
)

$ErrorActionPreference = "Stop"

$LabNetworkName = "capstone-lab"
$LabCidr = "10.77.0.0/24"
$KaliVmName = "Capstone-Kali"
$MetaVmName = "Capstone-Metasploitable2"

$DefaultKaliOvaUrl = "https://mega.nz/file/0GUEwQgB#YQUkPu9u_QXoTN5HA63KohK04eq4glC5_wi6QwXfeZw"
$DefaultMetasploitableOvaUrl = "https://mega.nz/file/JTUzkBQI#ezIFtYx-F8T56T5uoh0yVNSs-z4XrzeeA9CBLLg1z_A"
$DefaultJuiceShopTarUrl = "https://mega.nz/file/xTdhnDYI#KRsHtb3U9eAd0ZOcl3X--BCXukNA_o8y0JOpfidE9ds"
$DefaultDvwaTarUrl = "https://mega.nz/file/YPNUVCbT#7fD93gqqUaPXeNOXEhcmYTdPXTmuatKL8G_AqcnAWu0"
$DefaultSha256SumsUrl = "https://mega.nz/file/tGMDEAoR#FCHOw4k1e_EsI1JlwKgrwx_7eMpojOZAEY-udyXVD2g"

$AssetsDir = Join-Path $Root "assets"
$OvaDir = Join-Path $AssetsDir "ova"
$DockerDir = Join-Path $AssetsDir "docker"
$KaliOva = Join-Path $OvaDir "Capstone-Kali.ova"
$MetaOva = Join-Path $OvaDir "Capstone-Metasploitable2.ova"
$JuiceShopTar = Join-Path $DockerDir "juice-shop.tar"
$DvwaTar = Join-Path $DockerDir "dvwa.tar"
$Sha256Sums = Join-Path $AssetsDir "SHA256SUMS.txt"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message"
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Require-Command {
    param([string]$Name)
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $command) {
        throw "Missing required command: $Name"
    }
    return $command.Source
}

function Test-MegaUrl {
    param([string]$Url)
    return ($Url -match "^https://mega\.nz/")
}

function Add-MegaCmdToPath {
    $candidates = @()
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        if ($env:LOCALAPPDATA) {
            $candidates += (Join-Path $env:LOCALAPPDATA "MEGAcmd")
        }
        if ($env:ProgramFiles) {
            $candidates += (Join-Path $env:ProgramFiles "MEGAcmd")
        }
    }
    else {
        $candidates += "/Applications/MEGAcmd.app/Contents/MacOS"
    }

    foreach ($candidate in $candidates) {
        if ((Test-Path -LiteralPath $candidate) -and ($env:PATH -notlike "*$candidate*")) {
            $separator = [System.IO.Path]::PathSeparator
            $env:PATH = "$candidate$separator$env:PATH"
        }
    }
}

function Test-UsesMegaArtifacts {
    return (
        (Test-MegaUrl -Url $KaliOvaUrl) -or
        (Test-MegaUrl -Url $MetasploitableOvaUrl) -or
        (Test-MegaUrl -Url $JuiceShopTarUrl) -or
        (Test-MegaUrl -Url $DvwaTarUrl) -or
        (Test-MegaUrl -Url $Sha256SumsUrl)
    )
}

function Ensure-MegaCmd {
    Add-MegaCmdToPath
    if (Get-Command "mega-get" -ErrorAction SilentlyContinue) {
        return
    }

    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $winget = Get-Command "winget" -ErrorAction SilentlyContinue
        if (-not $winget) {
            throw "MEGAcmd is required for MEGA downloads, but 'mega-get' and 'winget' were not found. Install MEGAcmd from https://mega.nz/cmd and rerun setup."
        }

        Write-Host "MEGAcmd is missing. Installing MEGAcmd with winget..."
        & $winget.Source install --id Mega.MEGAcmd -e --source winget --accept-package-agreements --accept-source-agreements --silent --disable-interactivity | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Exact winget package install failed. Trying MEGAcmd name lookup..."
            & $winget.Source install MEGAcmd --source winget --accept-package-agreements --accept-source-agreements --silent --disable-interactivity | Out-Host
        }

        Add-MegaCmdToPath
        if (-not (Get-Command "mega-get" -ErrorAction SilentlyContinue)) {
            throw "MEGAcmd installation completed or was attempted, but 'mega-get' is still not available in PATH. Open a new terminal or add '$env:LOCALAPPDATA\MEGAcmd' to PATH, then rerun setup."
        }

        return
    }

    throw "MEGAcmd is required for MEGA downloads, but 'mega-get' was not found. On macOS, run scripts/setup-lab-macos.sh so it can install MEGAcmd with Homebrew."
}

function Find-VBoxManage {
    $command = Get-Command "VBoxManage" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @()
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $candidates += "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
        $candidates += "D:\viertual box\VBoxManage.exe"
    }
    else {
        $candidates += "/usr/local/bin/VBoxManage"
        $candidates += "/opt/homebrew/bin/VBoxManage"
        $candidates += "/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw "VirtualBox VBoxManage was not found. Install VirtualBox first, then rerun this script."
}

function Test-UnsupportedHost {
    $arch = ""
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $arch = $env:PROCESSOR_ARCHITECTURE
    }
    else {
        try {
            $arch = (& uname -m).Trim()
        }
        catch {
            $arch = ""
        }
    }

    if ($arch -match "arm64|aarch64") {
        throw "Unsupported host architecture '$arch'. These OVAs are x86/amd64 VirtualBox images and are not suitable for Apple Silicon/ARM64 hosts."
    }
}

function Load-Manifest {
    if (-not $ManifestPath) {
        $candidate = Join-Path $Root "lab-manifest.json"
        if (Test-Path -LiteralPath $candidate) {
            $script:ManifestPath = $candidate
        }
    }

    if ($ManifestPath -and (Test-Path -LiteralPath $ManifestPath)) {
        $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
        if (-not $KaliOvaUrl -and $manifest.kali_ova_url) {
            $script:KaliOvaUrl = $manifest.kali_ova_url
        }
        if (-not $MetasploitableOvaUrl -and $manifest.metasploitable_ova_url) {
            $script:MetasploitableOvaUrl = $manifest.metasploitable_ova_url
        }
        if (-not $JuiceShopTarUrl -and $manifest.juice_shop_tar_url) {
            $script:JuiceShopTarUrl = $manifest.juice_shop_tar_url
        }
        if (-not $DvwaTarUrl -and $manifest.dvwa_tar_url) {
            $script:DvwaTarUrl = $manifest.dvwa_tar_url
        }
        if (-not $Sha256SumsUrl -and $manifest.sha256sums_url) {
            $script:Sha256SumsUrl = $manifest.sha256sums_url
        }
    }

    if (-not $KaliOvaUrl) {
        $script:KaliOvaUrl = $DefaultKaliOvaUrl
    }
    if (-not $MetasploitableOvaUrl) {
        $script:MetasploitableOvaUrl = $DefaultMetasploitableOvaUrl
    }
    if (-not $JuiceShopTarUrl) {
        $script:JuiceShopTarUrl = $DefaultJuiceShopTarUrl
    }
    if (-not $DvwaTarUrl) {
        $script:DvwaTarUrl = $DefaultDvwaTarUrl
    }
    if (-not $Sha256SumsUrl) {
        $script:Sha256SumsUrl = $DefaultSha256SumsUrl
    }
}

function Download-MegaFile {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$Description
    )

    $megaGet = Get-Command "mega-get" -ErrorAction SilentlyContinue
    if ($megaGet) {
        $downloadDir = Join-Path $AssetsDir "_mega-downloads"
        Ensure-Directory $downloadDir
        $before = @{}
        Get-ChildItem -LiteralPath $downloadDir -File -ErrorAction SilentlyContinue | ForEach-Object {
            $before[$_.FullName] = $true
        }

        Write-Host "Downloading $Description with mega-get..."
        & $megaGet.Source $Url $downloadDir
        if ($LASTEXITCODE -ne 0) {
            throw "mega-get failed while downloading $Description."
        }

        $downloaded = Get-ChildItem -LiteralPath $downloadDir -File |
            Where-Object { -not $before.ContainsKey($_.FullName) } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if (-not $downloaded) {
            throw "mega-get finished but no new file was found for $Description."
        }

        Move-Item -LiteralPath $downloaded.FullName -Destination $OutFile -Force
        return
    }

    throw @"
$Description uses a MEGA URL. Install MEGAcmd and ensure 'mega-get' is available in PATH before running unattended setup.

Missing file: $OutFile
URL: $Url
"@
}

function Download-FileIfMissing {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$Description
    )

    if (Test-Path -LiteralPath $OutFile) {
        Write-Host "$Description already exists: $OutFile"
        return
    }

    if (-not $Url) {
        throw "$Description is missing and no download URL was provided. Set it in lab-manifest.json or pass it as a parameter."
    }

    if (Test-MegaUrl -Url $Url) {
        Download-MegaFile -Url $Url -OutFile $OutFile -Description $Description
    }
    else {
        Write-Host "Downloading $Description..."
        Invoke-WebRequest -Uri $Url -OutFile $OutFile
    }
}

function Get-ExpectedHash {
    param([string]$RelativePath)

    if (-not (Test-Path -LiteralPath $Sha256Sums)) {
        return ""
    }

    $normalized = $RelativePath.Replace("\", "/")
    foreach ($line in Get-Content -LiteralPath $Sha256Sums) {
        if ($line -match "^\s*([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($normalized))\s*$") {
            return $Matches[1].ToUpperInvariant()
        }
    }

    return ""
}

function Assert-FileHash {
    param(
        [string]$Path,
        [string]$RelativePath,
        [string]$Description
    )

    if ($SkipHashCheck) {
        return
    }

    $expected = Get-ExpectedHash -RelativePath $RelativePath
    if (-not $expected) {
        Write-Host "No checksum entry found for $RelativePath; skipping hash check."
        return
    }

    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne $expected) {
        throw "$Description checksum mismatch. Expected $expected but got $actual."
    }

    Write-Host "$Description checksum OK."
}

function Test-VmExists {
    param(
        [string]$VBoxManage,
        [string]$Name
    )
    $localVmConfig = Join-Path (Join-Path $Root "vms") (Join-Path $Name "$Name.vbox")
    if (Test-Path -LiteralPath $localVmConfig) {
        return $true
    }

    $quotedName = '"' + $Name + '"'
    $vms = & $VBoxManage list vms
    foreach ($vm in $vms) {
        if ($vm.StartsWith($quotedName + " ")) {
            return $true
        }
    }
    return $false
}

function Remove-VmIfRequested {
    param(
        [string]$VBoxManage,
        [string]$Name
    )

    if (Test-VmExists -VBoxManage $VBoxManage -Name $Name) {
        if (-not $ReplaceExisting) {
            Write-Host "VM already exists, leaving it unchanged: $Name"
            return $false
        }

        Write-Host "Removing existing VM because -ReplaceExisting was provided: $Name"
        try {
            & $VBoxManage controlvm $Name poweroff | Out-Null
        }
        catch {
        }
        & $VBoxManage unregistervm $Name --delete | Out-Host
    }

    return $true
}

function Ensure-NatNetwork {
    param([string]$VBoxManage)

    $networks = & $VBoxManage list natnets
    if (-not ($networks | Select-String -SimpleMatch "Name: $LabNetworkName")) {
        & $VBoxManage natnetwork add --netname $LabNetworkName --network $LabCidr --enable | Out-Host
    }

    try {
        & $VBoxManage natnetwork start --netname $LabNetworkName | Out-Null
    }
    catch {
    }
}

function Import-CapstoneVm {
    param(
        [string]$VBoxManage,
        [string]$Name,
        [string]$OvaPath
    )

    if (-not (Remove-VmIfRequested -VBoxManage $VBoxManage -Name $Name)) {
        return
    }

    & $VBoxManage import $OvaPath --vsys 0 --vmname $Name | Out-Host
}

function Configure-CapstoneVms {
    param([string]$VBoxManage)

    if (Test-VmExists -VBoxManage $VBoxManage -Name $KaliVmName) {
        & $VBoxManage modifyvm $KaliVmName --memory 4096 --cpus 2 --nic1 nat --nic2 natnetwork --nat-network2 $LabNetworkName | Out-Host
    }

    if (Test-VmExists -VBoxManage $VBoxManage -Name $MetaVmName) {
        & $VBoxManage modifyvm $MetaVmName --memory 1024 --cpus 1 --nic1 natnetwork --nat-network1 $LabNetworkName | Out-Host
    }
}

function Start-CapstoneVm {
    param(
        [string]$VBoxManage,
        [string]$Name
    )

    $running = & $VBoxManage list runningvms
    if ($running | Select-String -SimpleMatch "`"$Name`"") {
        Write-Host "VM already running: $Name"
        return
    }

    & $VBoxManage startvm $Name --type headless | Out-Host
}

function Start-DockerDesktopIfAvailable {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $dockerDesktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        if (Test-Path -LiteralPath $dockerDesktop) {
            Start-Process -FilePath $dockerDesktop -WindowStyle Hidden
        }
    }
    elseif ($IsMacOS) {
        try {
            & open -a Docker | Out-Null
        }
        catch {
        }
    }
}

function Wait-Docker {
    Require-Command "docker" | Out-Null
    $ready = $false
    for ($i = 0; $i -lt 60; $i++) {
        try {
            docker info | Out-Null
            $ready = $true
            break
        }
        catch {
            if ($i -eq 0) {
                Start-DockerDesktopIfAvailable
            }
            Start-Sleep -Seconds 2
        }
    }

    if (-not $ready) {
        throw "Docker is installed but not responding. Start Docker Desktop and rerun this script."
    }
}

function Load-DockerArchiveIfAvailable {
    param(
        [string]$Url,
        [string]$TarPath,
        [string]$Description
    )

    if ($Url -and -not (Test-Path -LiteralPath $TarPath)) {
        Download-FileIfMissing -Url $Url -OutFile $TarPath -Description $Description
    }

    if (Test-Path -LiteralPath $TarPath) {
        Write-Host "Loading Docker archive: $TarPath"
        docker load -i $TarPath | Out-Host
        return $true
    }

    return $false
}

Load-Manifest
Test-UnsupportedHost
Ensure-Directory $OvaDir
Ensure-Directory $DockerDir

Write-Step "Checking required tools"
$VBoxManage = Find-VBoxManage
Require-Command "docker" | Out-Null

if ($ValidateOnly) {
    Write-Step "Validating local assets and existing runtime"
    Write-Host "VBoxManage: $VBoxManage"
    docker --version
    & $VBoxManage --version
    if (Test-Path -LiteralPath $KaliOva) {
        Write-Host "Found local Kali OVA: $KaliOva"
    }
    elseif ($KaliOvaUrl) {
        Write-Host "Kali OVA URL configured: $KaliOvaUrl"
    }
    else {
        throw "Kali OVA is missing and no URL is configured."
    }

    if (Test-Path -LiteralPath $MetaOva) {
        Write-Host "Found local Metasploitable2 OVA: $MetaOva"
    }
    elseif ($MetasploitableOvaUrl) {
        Write-Host "Metasploitable2 OVA URL configured: $MetasploitableOvaUrl"
    }
    else {
        throw "Metasploitable2 OVA is missing and no URL is configured."
    }

    Write-Host "VM exists ($KaliVmName): $(Test-VmExists -VBoxManage $VBoxManage -Name $KaliVmName)"
    Write-Host "VM exists ($MetaVmName): $(Test-VmExists -VBoxManage $VBoxManage -Name $MetaVmName)"
    Add-MegaCmdToPath
    if (Test-UsesMegaArtifacts) {
        if (Get-Command "mega-get" -ErrorAction SilentlyContinue) {
            Write-Host "MEGA downloader found: mega-get."
        }
        else {
            Write-Host "MEGA downloader not found. Normal setup will try to install MEGAcmd automatically before downloading MEGA-hosted artifacts."
        }
    }
    Write-Step "Validation complete"
    return
}

Write-Step "Preparing VM images"
if (Test-UsesMegaArtifacts) {
    Ensure-MegaCmd
}
Download-FileIfMissing -Url $Sha256SumsUrl -OutFile $Sha256Sums -Description "SHA256 checksum file"
Download-FileIfMissing -Url $KaliOvaUrl -OutFile $KaliOva -Description "Capstone Kali OVA"
Download-FileIfMissing -Url $MetasploitableOvaUrl -OutFile $MetaOva -Description "Capstone Metasploitable2 OVA"
Assert-FileHash -Path $KaliOva -RelativePath "ova/Capstone-Kali.ova" -Description "Capstone Kali OVA"
Assert-FileHash -Path $MetaOva -RelativePath "ova/Capstone-Metasploitable2.ova" -Description "Capstone Metasploitable2 OVA"

Write-Step "Configuring VirtualBox lab network"
Ensure-NatNetwork -VBoxManage $VBoxManage

Write-Step "Importing VirtualBox VMs"
Import-CapstoneVm -VBoxManage $VBoxManage -Name $KaliVmName -OvaPath $KaliOva
Import-CapstoneVm -VBoxManage $VBoxManage -Name $MetaVmName -OvaPath $MetaOva
Configure-CapstoneVms -VBoxManage $VBoxManage

if (-not $SkipDockerStart) {
    Write-Step "Starting Docker targets"
    Wait-Docker
    $loadedJuiceShop = Load-DockerArchiveIfAvailable -Url $JuiceShopTarUrl -TarPath $JuiceShopTar -Description "Juice Shop Docker image archive"
    $loadedDvwa = Load-DockerArchiveIfAvailable -Url $DvwaTarUrl -TarPath $DvwaTar -Description "DVWA Docker image archive"
    if ($loadedJuiceShop) {
        Assert-FileHash -Path $JuiceShopTar -RelativePath "docker/juice-shop.tar" -Description "Juice Shop Docker image archive"
    }
    if ($loadedDvwa) {
        Assert-FileHash -Path $DvwaTar -RelativePath "docker/dvwa.tar" -Description "DVWA Docker image archive"
    }
    Push-Location $Root
    try {
        if (-not ($loadedJuiceShop -and $loadedDvwa)) {
            docker compose pull
        }
        docker compose up -d
    }
    finally {
        Pop-Location
    }
}

if (-not $SkipVmStart) {
    Write-Step "Starting VirtualBox VMs"
    Start-CapstoneVm -VBoxManage $VBoxManage -Name $KaliVmName
    Start-CapstoneVm -VBoxManage $VBoxManage -Name $MetaVmName
}

Write-Step "Lab setup complete"
Write-Host "DVWA:       http://localhost:8080"
Write-Host "Juice Shop: http://localhost:3000"
Write-Host "Kali VM:    $KaliVmName"
Write-Host "Target VM:  $MetaVmName"
