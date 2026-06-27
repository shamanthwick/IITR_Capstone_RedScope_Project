# Reconnaissance And Scan Plan

## Objectives

- Identify active lab hosts.
- Identify exposed ports and service versions.
- Identify web application directories and API surfaces.
- Create a clean target inventory before exploitation.

## Planned Evidence

| Phase | Evidence File |
| --- | --- |
| Host discovery | `03-evidence/recon/host-discovery.txt` |
| Port scan | `03-evidence/recon/nmap-services.txt` |
| Web directory scan | `03-evidence/recon/web-directories.txt` |
| Burp notes | `03-evidence/recon/burp-observations.md` |

## First Commands To Run From Kali

Commands should be reviewed after target IPs are known.

```bash
nmap -sn LAB_SUBNET
nmap -sV -sC -oN nmap-services.txt TARGET_IP
```

Do not scan outside the lab subnet.

## Current Lab Addresses

Use these for the first recon pass:

```text
Kali lab IP: 10.77.0.4
Metasploitable: 10.77.0.3
Juice Shop from Kali: http://192.169.1.29:3000
DVWA from Kali: http://192.169.1.29:8080
```
