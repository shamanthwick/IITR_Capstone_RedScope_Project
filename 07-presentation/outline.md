# RedScope Presentation Outline

## Team

- Shamanth R Singh
- Ajith Mohan
- Saiteja Kacham
- Madhurjya Deka

## Presentation Goal

Deliver a red-team debrief that explains the lab, the attack chain, the evidence, the ML experiment, the business impact, and the remediation plan in a clear 10-card format for Gamma AI.

## 10-Card Deck

### 1. Title Slide

- Project name: RedScope Capstone Red-Team Assessment
- Team names
- Course / batch / date
- Short subtitle: lab-only assessment of DVWA, OWASP Juice Shop, Metasploitable, and adversarial ML

Visual direction:

- clean cyber-themed title slide
- simple topology graphic or dark red-team background

### 2. Executive Summary

- What the project was
- What was tested
- What was proven
- Why it matters
- One-sentence bottom line: small lab weaknesses combined into a realistic compromise chain

### 3. Scope, Rules, and Lab Architecture

- Lab-only authorization
- In-scope targets: DVWA, Juice Shop, Metasploitable-like VM
- Out-of-scope: public targets, real data, denial-of-service, persistence
- Kali attacker VM
- Docker web apps on ports 8080 and 3000
- Metasploitable on the isolated lab network

Visual direction:

- one simple topology diagram
- include scope / out-of-scope callouts

### 4. Methodology and Reconnaissance

- Planning
- Reconnaissance
- Scanning
- Vulnerability assessment
- Evidence-first workflow
- Key recon results:
  - legacy services exposed
  - DVWA in low-security mode
  - Juice Shop `/ftp` exposure

### 5. Web Findings

- DVWA SQL injection proof of concept
- Juice Shop `/ftp` directory listing disclosure
- Impact:
  - unsafe query handling
  - sensitive file exposure
  - weak access control

Speaker note:

- keep this slide focused on web compromise and web disclosure

### 6. Network Finding

- Metasploitable bind shell on TCP 1524
- Direct root shell with no authentication
- Impact: full compromise of the target VM

Visual direction:

- show the shell result or a strong evidence screenshot
- make the severity obvious

### 7. Post-Exploitation and ATT&CK Mapping

- Limited enumeration after compromise
- Identity, host info, and network config checks
- ATT&CK mapping:
  - `T1595` Active Scanning
  - `T1190` Exploit Public-Facing Application
  - `T1082` System Information Discovery
  - `T1016` System Network Configuration Discovery

### 8. Adversarial ML Experiment

- Baseline detector built from a tiny request dataset
- Baseline result and evasion example
- Second defender with character n-grams
- Tradeoff: fewer evasions, more false positives
- Why the evasion worked: small dataset, narrow features

### 9. Business Impact and Recommendations

- Data exposure
- Unauthorized access
- Internal file disclosure
- Root compromise on a vulnerable host
- Recommended fixes:
  - remove unnecessary services
  - parameterize queries
  - restrict sensitive directories
  - strengthen access control
  - use layered detection

### 10. Team Roles and Closing

- Shamanth R Singh: scope, web exploit summary, overall coordination
- Ajith Mohan: network foothold and post-exploitation
- Saiteja Kacham: ML detector and evasion
- Madhurjya Deka: remediation and business impact
- Closing takeaway: layered defenses matter, and small weaknesses can combine into a full compromise chain

## Gamma Notes

- Keep each card short and visual
- Prefer diagrams, tables, and callouts over long text
- Use a professional red-team style, not a marketing style
- Keep the narrative linear: scope -> architecture -> recon -> exploit -> post-exploit -> ML -> impact -> remediation -> close

