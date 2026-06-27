# Lab Architecture

## Intended Hybrid Setup

- Kali Linux VM: attacker/testing workstation
- Docker container: DVWA
- Docker container: OWASP Juice Shop
- Standalone VM: Metasploitable-like target

## Network Goal

Kali must be able to reach:

- DVWA HTTP service
- Juice Shop HTTP service
- Metasploitable exposed services

The preferred setup is an isolated host-only or NAT lab network. Public internet access should be used only for installing tools and pulling lab images.

## Prerequisites To Confirm

| Component | Purpose | Status |
| --- | --- | --- |
| Docker Desktop or Docker Engine | Run DVWA and Juice Shop | Installed |
| Docker Compose | Start container lab | Installed |
| VirtualBox or VMware | Run Kali and Metasploitable | VirtualBox installed |
| Kali VM image | Testing workstation | Created as `Capstone-Kali` |
| Metasploitable VM image | Vulnerable Linux target | Imported as `Capstone-Metasploitable2` |

## Host Tool Check

Checked on 2026-06-27:

- Docker Desktop: 4.79.0
- Docker CLI: 29.5.3
- Docker Compose: v5.1.4
- VirtualBox: 7.2.10r174163
- Docker PATH added for future terminals: `C:\Program Files\Docker\Docker\resources\bin`
- VirtualBox PATH added for future terminals: `D:\viertual box`

## Running Web Targets

| Name | Host URL | Container | Status |
| --- | --- | --- | --- |
| OWASP Juice Shop | `http://localhost:3000` | `capstone-juice-shop` | Running |
| DVWA | `http://localhost:8080` | `capstone-dvwa` | Running |

## Running VM Targets

| Name | VM | Network | Address | Status |
| --- | --- | --- | --- | --- |
| Kali | `Capstone-Kali` | NAT + `capstone-lab` NAT Network | `10.0.2.15`, `10.77.0.4` | Running |
| Metasploitable | `Capstone-Metasploitable2` | `capstone-lab` NAT Network | `10.77.0.3` | Running |

Kali can reach Docker web apps through the Windows host Wi-Fi IP:

- Juice Shop: `http://192.169.1.29:3000`
- DVWA: `http://192.169.1.29:8080`

## Target Inventory

| Name | IP/URL | Notes |
| --- | --- | --- |
| Kali | `10.77.0.4` | Attacker VM on lab network |
| DVWA | `http://192.169.1.29:8080` | Docker web app from Kali |
| Juice Shop | `http://192.169.1.29:3000` | Docker web app from Kali |
| Metasploitable | `10.77.0.3` | Vulnerable VM |
