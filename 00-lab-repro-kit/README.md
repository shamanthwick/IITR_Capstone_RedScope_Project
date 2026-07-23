# 00-Lab Repro Kit

This folder is the reproducible lab setup package.

It shares configuration, provisioning helpers, and documentation so another person can recreate the same lab on their own machine from exported OVAs plus Docker targets.

## Core idea

- Keep Git focused on scripts, docs, and configuration
- Keep large VM and Docker image artifacts outside Git
- Use VirtualBox for the Kali and Metasploitable 2 VMs
- Use Docker Compose for DVWA and OWASP Juice Shop
- Use `scripts/setup-lab.ps1` as the single unattended setup entry point

## Full lab bootstrap

The mentor setup flow is:

1. Install prerequisites: Docker Desktop, VirtualBox, and PowerShell 7. The setup script can install MEGAcmd automatically when `mega-get` is missing.
2. Run the setup script:

```powershell
pwsh ./scripts/setup-lab.ps1
```

To validate prerequisites and local/cloud artifact configuration without importing or starting anything:

```powershell
pwsh ./scripts/setup-lab.ps1 -ValidateOnly
```

That script will:

- use the built-in MEGA links from `lab-manifest.example.json` / `setup-lab.ps1`
- download the Capstone Kali OVA if it is not already cached
- download the Capstone Metasploitable 2 OVA if it is not already cached
- download and verify `assets/SHA256SUMS.txt`
- create or reuse the VirtualBox `capstone-lab` NAT network
- import or reuse the Kali and Metasploitable 2 VMs
- download/load the Docker target archives, or pull from Docker Hub if archives are unavailable
- start DVWA, Juice Shop, Kali, and Metasploitable 2

MEGA links are not plain direct-download URLs. The setup script uses MEGAcmd `mega-get`; on Windows it attempts installation through `winget`, and on macOS Intel the wrapper attempts installation through Homebrew.

Quick check:

```powershell
mega-get --version
```

## Layout

```text
00-lab-repro-kit/
├── README.md
├── docker-compose.yml
├── assets/      # local/cloud artifacts; ignored by Git
├── scripts/
└── docs/
```

## What to commit

- automation scripts
- configuration files
- documentation
- sample data only if it is safe to share

## What not to commit

- Kali VM disks
- Metasploitable 2 VM disks
- snapshots
- installers
- ISO files
- secrets or private keys
- `lab-manifest.json` if it contains private cloud links

## Current state

- Docker web apps are defined for the lab
- Kali and Metasploitable 2 are exported as local OVA artifacts
- Docker targets can be loaded from the configured MEGA tar archives or pulled from Docker Hub
- Cleanup of local runtime state should only happen after approval

## Quick start

```powershell
cd "F:\RedScope Capstone Project\00-lab-repro-kit"
pwsh ./scripts/setup-lab.ps1
```

macOS Intel:

```bash
cd 00-lab-repro-kit
bash ./scripts/setup-lab-macos.sh
```

Target URLs:

- DVWA: `http://localhost:8080`
- Juice Shop: `http://localhost:3000`

## Recreate flow

1. Clone or unzip the repository.
2. Install Docker Desktop, VirtualBox, and PowerShell 7.
3. Keep the default MEGA links, override them in `lab-manifest.json`, or place the OVA/Docker archives in `assets/`.
4. Run `pwsh ./scripts/setup-lab.ps1`.
5. Verify the Docker and VM targets are up.
