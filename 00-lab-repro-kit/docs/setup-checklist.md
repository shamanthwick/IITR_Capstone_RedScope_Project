# Lab Setup Checklist

## Host requirements

- Docker Desktop or Docker Engine installed
- VirtualBox installed
- PowerShell 7 installed
- `mega-get` available in PATH, or package manager support available so setup can install MEGAcmd automatically
- Kali OVA available through `lab-manifest.json` or `assets/ova/Capstone-Kali.ova`
- Metasploitable 2 OVA available through `lab-manifest.json` or `assets/ova/Capstone-Metasploitable2.ova`
- Enough RAM for one attacker VM, one target VM, and two containers

## Bootstrap steps

1. Clone or copy this folder.
2. Keep the default MEGA links, or copy `lab-manifest.example.json` to `lab-manifest.json` and change the links if needed.
3. Run:

```powershell
pwsh ./scripts/setup-lab.ps1 -ValidateOnly
pwsh ./scripts/setup-lab.ps1
```

On macOS Intel, run:

```bash
bash ./scripts/setup-lab-macos.sh -ValidateOnly
bash ./scripts/setup-lab-macos.sh
```

4. Confirm the containers and VMs start successfully.
5. Use the runbook to verify networking.

## Notes

- Keep all scanning inside the lab subnet.
- Do not expose the lab to public networks.
