# Rules of Engagement

## Authorization

This assessment is limited to intentionally vulnerable lab systems owned or controlled by the student/operator.

## In-Scope Targets

| Target | Type | Address | Status |
| --- | --- | --- | --- |
| DVWA | Web app | `http://192.169.1.29:8080` from Kali, `http://localhost:8080` from Windows | In scope |
| OWASP Juice Shop | Web app | `http://192.169.1.29:3000` from Kali, `http://localhost:3000` from Windows | In scope |
| Metasploitable-like VM | Linux VM | `10.77.0.3` | In scope |

## Allowed Activities

- Host discovery against lab networks
- Service enumeration against lab targets
- Web application testing against DVWA and Juice Shop
- Controlled exploitation of documented lab vulnerabilities
- Local password-cracking exercises using lab-provided hashes only
- Post-exploitation enumeration inside lab VMs
- ML detector training and evasion using lab traffic examples

## Prohibited Activities

- Attacks against public IP addresses or real organizations
- Denial-of-service or stress testing
- Data destruction
- Exfiltration of real personal or business data
- Persistence mechanisms outside the lab
- Running AI-suggested commands without review

## Evidence Rules

- Record target, timestamp, command/tool, result, and impact.
- Capture screenshots or terminal output for each finding.
- Store evidence under `03-evidence/`.
- Do not store secrets unless they are intentionally part of the vulnerable lab.

## Stop Conditions

- Unexpected public target exposure
- Host instability outside the lab
- Discovery of non-lab credentials or sensitive data
- Any uncertainty about authorization

## Signature

Tester name: `Shamanth R Singh`

Signature: `Shamanth R Singh`

Date: `2026-06-28`

Status: Signed and acknowledged for lab-only Week 2 exploitation within the scope defined above.
