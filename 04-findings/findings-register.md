# Findings Register

| ID | Title | Target | Severity | Status |
| --- | --- | --- | --- | --- |
| F-001 | Multiple legacy remote services exposed | Metasploitable `10.77.0.3` | High | Recon validated |
| F-002 | Anonymous FTP login allowed | Metasploitable `10.77.0.3:21` | Medium | Recon validated |
| F-003 | Cleartext Telnet service exposed | Metasploitable `10.77.0.3:23` | Medium | Recon validated |
| F-004 | SMB message signing disabled on legacy Samba | Metasploitable `10.77.0.3:139/445` | Medium | Recon validated |
| F-005 | NFS/RPC services exposed | Metasploitable `10.77.0.3:111/2049` | Medium | Recon validated |
| F-006 | Metasploitable bind shell service exposed | Metasploitable `10.77.0.3:1524` | Critical | Exploited |
| F-007 | Legacy web stack exposes diagnostic/admin paths | Metasploitable `10.77.0.3:80` | High | Recon validated |
| F-008 | DVWA running in low-security lab mode | DVWA `192.169.1.29:8080` | High | Exploited |
| F-009 | Juice Shop exposes known challenge/API paths | Juice Shop `192.169.1.29:3000` | Medium | Recon validated |
| F-010 | Juice Shop FTP directory listing exposes confidential files | Juice Shop `http://localhost:3000/ftp` | Medium | Exploited |

## Initial Evidence Map

| Finding | Evidence |
| --- | --- |
| F-001 | `03-evidence/recon/week1-recon-raw.md`, Nmap service enumeration |
| F-002 | `03-evidence/recon/week1-recon-raw.md`, `ftp-anon` script result |
| F-003 | `03-evidence/recon/week1-recon-raw.md`, Nmap service enumeration |
| F-004 | `03-evidence/recon/week1-recon-raw.md`, SMB script result |
| F-005 | `03-evidence/recon/week1-recon-raw.md`, RPC/NFS services |
| F-006 | `03-evidence/recon/week1-recon-raw.md`, TCP 1524 bindshell, `03-evidence/network/metasploitable-bind-shell-root.md` |
| F-007 | `03-evidence/recon/week1-recon-raw.md`, Gobuster and WhatWeb output |
| F-008 | `03-evidence/recon/week1-recon-raw.md`, WhatWeb cookie `security=low`, `03-evidence/web/dvwa-sqli-poc.md` |
| F-009 | `03-evidence/recon/week1-recon-raw.md`, Gobuster output |
| F-010 | `03-evidence/web/juice-shop-ftp-directory-listing.md` |

## Severity Guide

- Critical: direct full compromise or severe business impact
- High: reliable compromise of sensitive function or account
- Medium: meaningful security weakness with constraints
- Low: hardening issue or limited impact
- Informational: observation useful for context
