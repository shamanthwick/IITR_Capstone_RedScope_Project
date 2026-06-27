# Install And Runtime Status

## Current status

The lab is designed to be bootstrapped from source control and the official upstream downloads.

## Required components

- Docker Desktop
- VirtualBox
- Vagrant
- PowerShell 7 or Windows PowerShell
- `7z` for unpacking the Kali image, if your system does not already have a compatible archive tool

## Runtime verification

```powershell
docker --version
docker compose version
VBoxManage --version
```

## Expected lab targets

- DVWA at `http://localhost:8080`
- Juice Shop at `http://localhost:3000`
- Kali VM at `RedScope-Kali`
- Metasploitable VM at `RedScope-Metasploitable2`

