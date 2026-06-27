# Week 1 Recon Report

## Objective

Complete Week 1 RedScope requirements: verify scope, perform reconnaissance, run initial scanning, and prepare an initial findings list without exploitation.

## Scope

| Target | Address | Purpose |
| --- | --- | --- |
| Capstone-Kali | `10.77.0.4` | Attacker workstation |
| Capstone-Metasploitable2 | `10.77.0.3` | Network/service target |
| OWASP Juice Shop | `http://192.169.1.29:3000` | Modern web app target |
| DVWA | `http://192.169.1.29:8080` | Classic web vulnerability target |

## Methodology

- Confirmed lab-only scope.
- Performed host discovery on `10.77.0.0/24`.
- Enumerated Metasploitable services with Nmap service/version detection and default scripts.
- Fingerprinted web applications with WhatWeb.
- Performed lightweight directory discovery with Gobuster.
- Deduplicated observations into an initial findings register.

## Host Inventory

| Address | Role | Notes |
| --- | --- | --- |
| `10.77.0.1` | VirtualBox NAT Network gateway | Infrastructure |
| `10.77.0.2` | VirtualBox NAT Network service | Infrastructure |
| `10.77.0.3` | Metasploitable | Vulnerable Linux target |
| `10.77.0.4` | Kali | Testing workstation |

## Key Observations

- Metasploitable exposes many legacy services, including FTP, Telnet, Samba, RSH, NFS, MySQL, PostgreSQL, VNC, UnrealIRCd, and Tomcat.
- Metasploitable exposes a known lab bind shell service on TCP `1524`.
- DVWA is reachable and configured with `security=low`.
- Juice Shop is reachable and exposes expected application paths such as `/ftp`, `/rest`, `/api`, `/redirect`, and `/restricted`.
- Metasploitable web service exposes `phpinfo.php`, `phpMyAdmin`, WebDAV, and TWiki paths.

## Initial Risk Themes

- Legacy and vulnerable service versions on the Linux target.
- Cleartext remote access services such as Telnet and FTP.
- Web applications intentionally configured for vulnerable testing.
- Sensitive diagnostic or administrative web paths exposed in the lab.

## Next Step

Do not proceed to exploitation until the Rules of Engagement is signed/acknowledged. After that, select:

- One web exploit path, likely DVWA SQL injection or Juice Shop access-control/API issue.
- One network exploit path, likely Metasploitable FTP, Samba, UnrealIRCd, Tomcat, or the lab bind shell.
