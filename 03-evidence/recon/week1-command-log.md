# Week 1 Command Log

Date: 2026-06-28 local / 2026-06-27 Kali VM time

## Scope

| Target | Address |
| --- | --- |
| Capstone lab subnet | `10.77.0.0/24` |
| Metasploitable | `10.77.0.3` |
| OWASP Juice Shop | `http://192.169.1.29:3000` |
| DVWA | `http://192.169.1.29:8080` |

## AI Assistant Use

The AI assistant was used to structure the Week 1 workflow, select reconnaissance commands, interpret outputs, and draft documentation. Each command below was reviewed for lab-only scope before execution.

## Commands

| ID | Command | Purpose | Scope Check |
| --- | --- | --- | --- |
| C-001 | `nmap -sn 10.77.0.0/24` | Discover active hosts on isolated VM lab subnet | Lab subnet only |
| C-002 | `nmap -sV -sC 10.77.0.3` | Enumerate services and safe default scripts on Metasploitable | Single lab VM |
| C-003 | `whatweb http://192.169.1.29:3000 http://192.169.1.29:8080 http://10.77.0.3` | Fingerprint lab web apps | Lab web targets only |
| C-004 | `gobuster dir -u http://10.77.0.3 -w /usr/share/wordlists/dirb/common.txt -q -t 20 --timeout 10s` | Directory discovery on Metasploitable web service | Single lab VM |
| C-005 | `gobuster dir -u http://192.169.1.29:8080 -w /usr/share/wordlists/dirb/common.txt -q -t 20 --timeout 10s` | Directory discovery on DVWA | Lab web app only |
| C-006 | `gobuster dir -u http://192.169.1.29:3000 -w /usr/share/wordlists/dirb/common.txt -q -t 20 --timeout 10s --exclude-length 9903` | Directory discovery on Juice Shop, excluding SPA wildcard responses | Lab web app only |

## Notes

- No exploitation was performed.
- No public IP ranges or third-party targets were scanned.
- Juice Shop required wildcard response handling because unknown paths returned a 200 response with length `9903`.
