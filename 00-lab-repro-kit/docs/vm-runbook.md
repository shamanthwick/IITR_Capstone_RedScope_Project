# Capstone VM Runbook

## VirtualBox storage

The setup process imports the exported Capstone OVAs and keeps the VMs under the VirtualBox default machine storage path.

## Capstone VMs

| VM | Purpose | Status |
| --- | --- | --- |
| Capstone-Kali | Attacker workstation | Imported from `Capstone-Kali.ova` |
| Capstone-Metasploitable2 | Vulnerable Linux target | Imported from `Capstone-Metasploitable2.ova` |

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

Use the setup script to create the lab, and the stop script to shut it down cleanly:

```powershell
pwsh ./scripts/setup-lab.ps1
.\scripts\stop-lab.ps1
```
