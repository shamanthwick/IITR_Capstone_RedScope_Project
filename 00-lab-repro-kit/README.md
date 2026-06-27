# 00-Lab Repro Kit

This folder is the IaC-friendly version of the lab.

It shares configuration, provisioning helpers, and documentation so another person can recreate the same lab on their own machine without copying the VM disks.

## Core idea

- Share config, not VM images
- Keep the lab reproducible from source
- Use VirtualBox or VMware for the runtime layer
- Use Vagrant plus scripts or Ansible for repeatable setup

## Full lab bootstrap

This repo can recreate the full lab from the official VM downloads.

Then run:

```powershell
.\scripts\bootstrap-lab.ps1
```

That script will:

- download the official Kali image if it is not already cached
- download the official Metasploitable 2 package if it is not already cached
- create or reuse the VirtualBox `capstone-lab` NAT network
- start the Docker targets
- create and start the Kali and Metasploitable 2 VMs

## Layout

```text
00-lab-repro-kit/
├── README.md
├── Vagrantfile
├── docker-compose.yml
├── assets/
├── ansible/
├── scripts/
└── docs/
```

## What to commit

- `Vagrantfile`
- automation scripts
- Ansible playbooks
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

## Current state

- Docker web apps are defined for the lab
- Kali and Metasploitable 2 VMs are powered off
- The original folders are still preserved until cleanup is approved

## Quick start

```powershell
cd "F:\for project\00-lab-repro-kit"
docker compose up -d
```

Target URLs:

- DVWA: `http://localhost:8080`
- Juice Shop: `http://localhost:3000`

## Recreate flow

1. Clone the repository.
2. Install Docker, VirtualBox, and Vagrant.
3. Run `.\scripts\bootstrap-lab.ps1`.
4. Verify the Docker and VM targets are up.
