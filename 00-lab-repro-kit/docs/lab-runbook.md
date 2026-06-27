# Lab Runbook

## Installed components

- Docker Desktop installed and running
- Docker Compose available
- VirtualBox 7.2.10 installed
- Kali VM created as `Capstone-Kali`
- Metasploitable 2 VM imported as `Capstone-Metasploitable2`

## Runtime verification

```powershell
docker --version
docker compose version
VBoxManage --version
```

```powershell
cd "F:\for project\00-lab-repro-kit"
docker compose up -d
docker ps
```

Expected containers:

- `capstone-juice-shop` on `http://localhost:3000`
- `capstone-dvwa` on `http://localhost:8080`

Expected VMs:

- `Capstone-Kali`
- `Capstone-Metasploitable2`

## VM storage

VirtualBox machine files are kept under:

```text
F:\for project\00-lab\vms
```

## Network layout

- Kali adapter 1: NAT
- Kali adapter 2: `capstone-lab` NAT Network
- Metasploitable: `capstone-lab` NAT Network

Lab subnet:

```text
10.77.0.0/24
```

## Start and stop

```powershell
VBoxManage startvm "Capstone-Kali" --type headless
VBoxManage startvm "Capstone-Metasploitable2" --type headless
```

```powershell
VBoxManage controlvm "Capstone-Kali" acpipowerbutton
VBoxManage controlvm "Capstone-Metasploitable2" acpipowerbutton
```

If graceful shutdown fails:

```powershell
VBoxManage controlvm "Capstone-Kali" poweroff
VBoxManage controlvm "Capstone-Metasploitable2" poweroff
```

## Notes

- Keep all scanning inside the lab subnet.
- Do not expose DVWA, Juice Shop, or Metasploitable to public networks.
- Keep the original `00-lab` and `repro-kit` folders until cleanup is approved.

