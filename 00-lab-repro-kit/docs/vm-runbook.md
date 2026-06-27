# Capstone VM Runbook

## VirtualBox storage

The bootstrap process creates the VMs locally and keeps them under the VirtualBox default machine storage path.

## Capstone VMs

| VM | Purpose | Status |
| --- | --- | --- |
| RedScope-Kali | Attacker workstation | Created by bootstrap |
| RedScope-Metasploitable2 | Vulnerable Linux target | Created by bootstrap |

## Network layout

| Network | Purpose |
| --- | --- |
| `capstone-lab` NAT Network | Isolated lab network for the VMs |

## Verification commands

From the host:

```powershell
docker ps
```

From Kali:

```bash
ip -br addr
nmap -sn 10.77.0.0/24
```

## Start and stop

Use the bootstrap script to create the lab, and the stop script to shut it down cleanly:

```powershell
.\scripts\bootstrap-lab.ps1
.\scripts\stop-lab.ps1
```

