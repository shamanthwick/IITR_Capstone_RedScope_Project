# Lab Setup Checklist

## Host requirements

- Docker Desktop or Docker Engine installed
- VirtualBox installed
- Kali image available through the bootstrap script
- Metasploitable 2 image available through the bootstrap script
- Enough RAM for one attacker VM, one target VM, and two containers

## Bootstrap steps

1. Clone or copy this folder.
2. Run:

```powershell
.\scripts\bootstrap-lab.ps1
```

3. Confirm the containers and VMs start successfully.
4. Use the runbook to verify networking.

## Notes

- Keep all scanning inside the lab subnet.
- Do not expose the lab to public networks.

