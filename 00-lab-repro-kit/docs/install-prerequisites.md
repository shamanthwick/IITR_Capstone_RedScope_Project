# Install And Runtime Status

## Current status

The lab is designed to be bootstrapped from source control plus the exported Capstone OVA files.

## Required components

- Docker Desktop
- VirtualBox
- PowerShell 7
- MEGA command-line downloader: `mega-get` from MEGAcmd. If it is missing, the setup script attempts to install MEGAcmd automatically.

Windows PowerShell 5.1 can run most of the script on Windows, but PowerShell 7 is the intended cross-platform runtime.

## Platform support

- Supported: Windows 11 x64
- Supported: Intel macOS with VirtualBox support
- Not supported as-is: Apple Silicon/ARM64 Macs, because these OVAs are x86/amd64 VirtualBox guests

## Runtime verification

```powershell
docker --version
docker compose version
VBoxManage --version
```

## Expected lab targets

- DVWA at `http://localhost:8080`
- Juice Shop at `http://localhost:3000`
- Kali VM at `Capstone-Kali`
- Metasploitable VM at `Capstone-Metasploitable2`

## Mentor setup command

Windows:

```powershell
pwsh ./scripts/setup-lab.ps1
```

macOS Intel:

```bash
bash ./scripts/setup-lab-macos.sh
```

The provided MEGA artifact links are already included in the default manifest template and setup script. `lab-manifest.json` is only needed if the links change.

Automatic MEGAcmd install behavior:

- Windows: uses `winget install` for MEGAcmd.
- macOS Intel: `setup-lab-macos.sh` uses Homebrew cask `megacmd-app`.
