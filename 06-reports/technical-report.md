# Technical Report

## Project

RedScope Capstone Red-Team Assessment

## Team

- Shamanth R Singh
- Ajit Mohan
- Saiteja Kacham
- Madhurjya Deka

## Abstract

This report documents a controlled red-team style assessment of a lab environment built from DVWA, OWASP Juice Shop, and a Metasploitable-like Linux VM. The work followed a signed lab-only Rules of Engagement and focused on three deliverables required by the capstone: reproducible exploitation, post-exploitation analysis, and a toy adversarial-ML experiment. The assessment produced one critical finding, three high findings, and six medium findings in the final register.

The main technical outcome is straightforward. The lab contained a classic SQL injection path in DVWA, a browsable file disclosure issue in Juice Shop, and a root-level bind shell on Metasploitable. Those findings were validated with terminal evidence and converted into a narrative that links reconnaissance, exploitation, enumeration, and machine-learning evasion. The conclusion is not that a single control failed, but that the attack surface was large enough for multiple independent weaknesses to combine into a compromise chain.

## 1. Engagement Overview

The capstone simulates a professional pentest/red-team workflow. The work was organized around the following phases:

1. planning and authorization
2. reconnaissance
3. scanning and enumeration
4. vulnerability assessment
5. exploitation
6. post-exploitation
7. documentation
8. ML detector construction
9. adversarial evasion testing
10. reporting and debrief

This structure matches the project brief and mirrors common PTES/OWASP-style testing practice: confirm scope, inventory the environment, validate the highest-risk issues first, and then write up business impact with clear evidence.

## 2. Rules of Engagement

The signed RoE defines the allowed lab targets and the activities that were permitted. The relevant constraints were:

- only attack the lab systems
- do not touch public or external targets
- do not perform denial-of-service activity
- do not exfiltrate real data
- keep command and evidence logs
- stop if something unexpected or out of scope appears
- review any AI-suggested command before execution

The signature recorded on the RoE is `Shamanth R Singh`. The signed document is important because it establishes that the work was authorized inside the lab and that the evidence was collected under a defined scope.

## 3. Environment and Architecture

The lab used a hybrid setup:

- Kali Linux as the attacker VM
- Docker-based web applications for DVWA and Juice Shop
- Metasploitable-like Linux VM for legacy service and privilege escalation practice

The isolation model mattered. The attacker VM and targets were placed in a private lab network so that all interaction stayed inside the environment. This allows repeatable evidence collection and keeps the assessment aligned with the engagement rules.

### 3.1 Target inventory

| Target | Address | Role |
| --- | --- | --- |
| DVWA | `http://localhost:8080` on the host, `http://192.169.1.29:8080` from Kali | Classic vulnerable web app |
| OWASP Juice Shop | `http://localhost:3000` on the host, `http://192.169.1.29:3000` from Kali | Modern vulnerable web app |
| Metasploitable-like VM | `10.77.0.3` | Legacy Linux service target |

## 4. Methodology

The methodology was deliberately conservative. The team did not attempt every possible exploit. Instead, it prioritized reproducible paths that could be defended in a report:

- enumerate the attack surface
- identify obviously vulnerable services first
- validate one web exploit cleanly
- validate one network exploit with strong impact
- record post-exploitation output without escalating beyond the lab
- build a tiny ML detector and test it against obfuscated payloads

That approach is appropriate for a capstone because it produces clear evidence and a defensible narrative. It also avoids wasting time on weak leads that do not contribute to the final deliverables.

## 5. Reconnaissance Results

Reconnaissance confirmed the following high-level facts:

- Metasploitable exposed multiple legacy services, including FTP, Telnet, SMB, NFS/RPC, Tomcat, and a direct bind shell
- DVWA was available in low-security lab mode
- Juice Shop exposed normal application routes plus a browsable `/ftp` path
- The lab network was isolated and stable for repeated testing

These results were enough to build the findings register and prioritize the later attack chain.

## 6. Findings Register Summary

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

The final report focuses on the exploited items and the supporting recon findings that make the compromise chain plausible.

## 7. Web Exploitation

### 7.1 DVWA SQL injection

The first web proof-of-concept used the DVWA SQL injection endpoint in low-security mode. The database was reset through `setup.php` so the test began from the expected lab state.

The final validated input was:

```text
/vulnerabilities/sqli/?id=1' or '1'='1&Submit=Submit
```

The response returned multiple database rows instead of a single lookup result. That behavior confirms that user-controlled input reached the SQL query unsafely. From a security standpoint, the issue is not simply that the page "looked wrong." The important part is that the application accepted crafted input and changed query behavior in a predictable way.

Technical impact:

- unauthorized data exposure
- evidence of unsafe query construction
- a reproducible input-to-output vulnerability

Evidence file:

- `03-evidence/web/dvwa-sqli-poc.md`

### 7.2 Juice Shop `/ftp` directory listing

The second web proof-of-concept targeted the Juice Shop `/ftp` directory. The route responded with a browsable directory listing and exposed readable files, including `legal.md`.

Observed commands:

```powershell
Invoke-WebRequest 'http://localhost:3000/ftp' | Select-Object -ExpandProperty Content
Invoke-WebRequest 'http://localhost:3000/ftp/legal.md' | Select-Object -ExpandProperty Content
```

The risk here is access control, not code execution. A web server should not expose internal documentation directories just because the path is known. The listing also disclosed filenames that could support later attacks by revealing how the application stores internal or backup material.

Technical impact:

- information disclosure
- weak directory protection
- attack-surface expansion through exposed filenames and document content

Evidence file:

- `03-evidence/web/juice-shop-ftp-directory-listing.md`

## 8. Network Exploitation

### 8.1 Metasploitable bind shell

The strongest network finding was the bind shell exposed on TCP `1524`. The service returned a root shell directly and required no credential guessing.

Command used from Kali:

```bash
printf "id\nuname -a\nexit\n" | nc -nv 10.77.0.3 1524
```

Observed result:

- connected to `root@metasploitable:/#`
- `id` returned `uid=0(root) gid=0(root) groups=0(root)`
- `uname -a` returned the kernel and host string

This is effectively full compromise for the target VM. In a real environment, a service like this would be a priority-one incident because it gives an attacker direct command execution as root.

Evidence file:

- `03-evidence/network/metasploitable-bind-shell-root.md`

### 8.2 Supporting legacy exposure

Other exposed services on the same host reinforced the risk picture:

- FTP with anonymous access
- Telnet in cleartext
- SMB services with weak hardening
- NFS/RPC exports
- web stack paths that could reveal further application details

Those services were not all exploited in depth, but they shaped the threat model and explain why the host was considered highly vulnerable.

## 9. Post-Exploitation

The post-exploitation phase remained inside the lab and focused on enumeration rather than persistence. After root-level access on Metasploitable, the team collected basic host context to document what a successful attacker could see:

- effective user context
- hostname and kernel string
- network configuration
- general system exposure

This was enough to support the narrative without drifting into unnecessary or unsafe activity.

### 9.1 Why post-exploitation mattered

The purpose of this stage was to show that compromise is not the end of the story. Once an attacker has root access on a host, they can enumerate configuration, inspect services, identify adjacent systems, and prepare for lateral movement. The capstone asked for simulation of that impact, not real data movement, and that boundary was respected.

### 9.2 ATT&CK mapping

| Phase | Example behavior | ATT&CK technique |
| --- | --- | --- |
| Reconnaissance | Enumerating hosts and services | `T1595` Active Scanning |
| Initial Access | DVWA SQL injection | `T1190` Exploit Public-Facing Application |
| Initial Access | Metasploitable bind shell | `T1133` External Remote Services / service exposure context |
| Discovery | Checking system identity and configuration | `T1082` System Information Discovery |
| Discovery | Enumerating network settings | `T1016` System Network Configuration Discovery |
| Collection | Reading exposed lab files | `T1213` Data from Information Repositories |

The mapping is intentionally conservative. It does not claim real-world persistence or lateral movement, because the lab work stopped at controlled enumeration.

## 10. ML Detector Experiment

The capstone included a small adversarial-ML exercise. The purpose was not to build a production detection system. The purpose was to show how feature choice affects evasion resistance.

### 10.1 Baseline detector

The first model used token-level features from a small request sample set. The baseline run produced:

```text
[[3 0]
 [1 2]]
```

Key metrics from the recorded run:

- accuracy: `0.83`
- attack recall: `0.67`
- normal recall: `1.00`

Interpretation:

- the model was good at recognizing normal requests in the tiny dataset
- it missed at least one attack sample
- it was vulnerable to at least one URL-encoded evasion example

Evidence:

- `03-evidence/ml/detector-run-2026-06-28.md`

### 10.2 Evasion behavior

The recorded evasion observation was simple:

- a URL-encoded XSS-style payload was classified as `normal`
- SQLi-style variants with encoding, comments, or mixed case still trended toward `attack`

That result is useful because it shows that the detector was not learning the full concept of maliciousness. It was learning narrow surface patterns from a small sample set.

### 10.3 Second defender comparison

A second model based on character n-grams was tested as a more robust defender. The recorded confusion matrix was:

```text
[[2 1]
 [1 2]]
```

That defender classified all four evasion samples as `attack`, which is better than the baseline in this toy setting. However, it also introduced an extra false positive on a normal sample. The tradeoff is the point: a stronger feature representation can reduce evasion, but it does not guarantee a clean outcome.

Evidence:

- `03-evidence/ml/defender-comparison-2026-06-28.md`

### 10.4 What the ML experiment proves

The experiment supports three conclusions:

1. a small model can be fooled by simple obfuscation
2. a slightly stronger model can resist that same evasion
3. neither model is ready for production without better data, validation, and layered controls

This aligns with the project requirement to explain why evasion worked rather than pretending the detector is a finished security product.

## 11. Attack Narrative Timeline

| Order | Phase | Evidence | ATT&CK tag |
| --- | --- | --- | --- |
| 1 | Scope and authorization | `01-planning/rules-of-engagement.md` | Governance |
| 2 | Reconnaissance | `03-evidence/recon/week1-recon-raw.md` | `T1595` |
| 3 | DVWA SQLi validation | `03-evidence/web/dvwa-sqli-poc.md` | `T1190` |
| 4 | Juice Shop directory disclosure | `03-evidence/web/juice-shop-ftp-directory-listing.md` | `T1213` |
| 5 | Metasploitable bind shell | `03-evidence/network/metasploitable-bind-shell-root.md` | Initial access / service abuse |
| 6 | Post-exploitation enumeration | `03-evidence/post-exploitation/metasploitable-root-enum.md` | `T1082`, `T1016` |
| 7 | Baseline ML training | `03-evidence/ml/detector-run-2026-06-28.md` | Defensive analytics |
| 8 | Defender comparison | `03-evidence/ml/defender-comparison-2026-06-28.md` | Defensive analytics |

## 12. Business Impact

The business impact of this exercise is best understood as a chain:

- a vulnerable web input can expose data
- exposed files can reveal internal details
- a forgotten service can give an attacker root access
- once root access exists, compromise expands from one issue to a system-level incident

In a real organization, the cost would likely be measured in incident response time, service disruption, regulatory exposure, and reputational damage. Even if the initial weakness looks minor, a chain of minor weaknesses can become a major event.

## 13. Remediation Priorities

### Priority 1: Remove or isolate exposed services

Any unnecessary service should be disabled or restricted. Especially important are legacy services that offer cleartext access or direct shells.

### Priority 2: Fix input handling in web applications

Use parameterized database queries and server-side validation. Treat every user-controlled field as untrusted.

### Priority 3: Restrict sensitive file access

Do not expose internal directories over HTTP. Ensure that backups, support artifacts, and internal documents are not reachable without authorization.

### Priority 4: Improve authentication and access control

Anonymous access and weakly protected paths should be removed. Access should be explicit, logged, and least-privilege by default.

### Priority 5: Strengthen detection design

If an ML detector is used, it should be trained on larger and more varied data, tested against obfuscation, and paired with rule-based and behavioral controls.

## 14. Reporting Quality and Evidence Standards

The project grading rubric emphasizes discipline as much as exploitation. The evidence standard used here was:

- record the command
- record the target and date
- capture the result
- explain the impact in one sentence
- link the evidence file in the report

That discipline matters because a security report is only useful if someone else can follow it. A good report should let a reviewer answer three questions:

- what happened
- why it matters
- what should be fixed first

## 15. Per-Finding Technical Notes

### F-001: Multiple legacy remote services exposed

Metasploitable exposed several services associated with older attack paths. The issue is not only the presence of any single service, but the overall breadth of exposure. A host with multiple legacy protocols invites enumeration, brute force, relay abuse, and chained exploitation.

### F-002: Anonymous FTP login allowed

Anonymous FTP access reduces the effort required to inspect a target. Even when it does not immediately lead to code execution, it often leaks file names, directory structure, and operational mistakes that support later attack steps.

### F-003: Cleartext Telnet service exposed

Telnet transmits content without encryption. In a real environment that creates immediate credential exposure risk. In the lab it serves as a clear example of outdated transport hygiene and poor service hardening.

### F-004: SMB message signing disabled

Weak SMB hardening matters because SMB is often used in environments where relay and impersonation attacks become relevant. This lab finding is a configuration weakness rather than a direct exploit, but it still contributes to the attack surface.

### F-005: NFS/RPC services exposed

NFS and RPC are useful services when tightly controlled. They become risky when exposure is broader than intended, because exported content and service metadata can be enumerated by an attacker.

### F-006: Metasploitable bind shell service exposed

This was the most severe issue in the lab. The bind shell returned a root shell directly, without credential checks. That means the host was already effectively compromised from a confidentiality, integrity, and availability standpoint.

### F-007: Legacy web stack exposes diagnostic/admin paths

The web stack included paths typical of older or intentionally vulnerable deployments. Even when such paths are not directly exploited, they can reveal version information, sample content, and admin cues that help a later attacker.

### F-008: DVWA running in low-security lab mode

This finding was expected in the capstone, but it still needed validation. The low-security mode made the SQL injection reproducible and provided a clean proof of unsafe database interaction.

### F-009: Juice Shop exposes known challenge/API paths

Juice Shop is intentionally structured to expose learning opportunities, but the assessment still treats these as findings because they demonstrate the way modern applications can expose multiple public routes that deserve review.

### F-010: Juice Shop FTP directory listing exposes confidential files

This finding is easy to explain to a non-technical reader because the effect is visible immediately. A directory listing and readable file content on a public route are direct examples of accidental information disclosure.

## 16. Attack Chain Interpretation

The assessment is best understood as a sequence of attacker decisions.

First, the attacker inventories the surface. Recon shows which hosts are alive, which services are listening, and where the web apps are located.

Second, the attacker chooses the most reliable entry points. In this lab, those were DVWA SQL injection and the Metasploitable bind shell. Juice Shop added an exposure case that was easier to explain to a business audience because it was pure information disclosure.

Third, the attacker uses post-exploitation to understand the host. Enumeration after a successful compromise matters because it shows the difference between a one-off bug and actual system control.

Fourth, the attacker tests the defense. The ML experiment shows whether the same malicious idea still works once it is obfuscated. The baseline failed on one encoded sample; the second defender improved, but at a cost in false positives.

This sequence mirrors real incidents. Attackers do not need every control to fail. They only need one dependable path through the stack.

## 17. Remediation Roadmap

### Immediate actions

- remove or isolate the bind shell and any unnecessary exposed service
- disable anonymous access on file-transfer services unless the lab explicitly requires it
- restrict or remove browsable sensitive directories
- reset weak lab credentials and confirm safe defaults after every reset

### Short-term actions

- parameterize all database queries
- review web routes for accidental file exposure
- harden legacy protocol configurations
- document and verify what each target is allowed to expose in the lab

### Medium-term actions

- use layered detection rather than relying on one ML model
- expand the defender training set with obfuscated and encoded payload examples
- add validation cases that include normal traffic variants so false positives are tracked

### Verification strategy

After each fix, rerun the same proof of concept and confirm that the result changes in the expected direction. The report is stronger when it states not only what failed, but how the team would check that the fix actually worked.

## 18. Limitations and Assumptions

This assessment deliberately worked within a constrained lab. That is appropriate for the capstone, but it means a few findings should not be overgeneralized:

- the environment is intentionally vulnerable
- the attack techniques were selected for reproducibility, not for maximum aggressiveness
- the ML models were tiny prototypes, not production systems
- the evidence is sufficient for the assignment, but not intended as a substitute for a full enterprise test

Those limits do not weaken the project. They make the scope honest.

## 19. Appendix A: Evidence Index

| Evidence file | Purpose |
| --- | --- |
| `01-planning/rules-of-engagement.md` | Authorization and lab scope |
| `03-evidence/recon/week1-recon-raw.md` | Original recon and service enumeration notes |
| `03-evidence/web/dvwa-sqli-poc.md` | DVWA SQL injection proof of concept |
| `03-evidence/web/juice-shop-ftp-directory-listing.md` | Juice Shop directory disclosure proof of concept |
| `03-evidence/network/metasploitable-bind-shell-root.md` | Root bind shell proof of concept |
| `03-evidence/post-exploitation/metasploitable-root-enum.md` | Controlled post-exploitation enumeration |
| `03-evidence/ml/detector-run-2026-06-28.md` | Baseline ML detector results |
| `03-evidence/ml/defender-comparison-2026-06-28.md` | Second defender comparison |

## 20. Appendix B: Representative Commands

```powershell
Invoke-WebRequest 'http://localhost:3000/ftp' | Select-Object -ExpandProperty Content
Invoke-WebRequest 'http://localhost:3000/ftp/legal.md' | Select-Object -ExpandProperty Content
```

```text
/vulnerabilities/sqli/?id=1' or '1'='1&Submit=Submit
```

```bash
printf "id\nuname -a\nexit\n" | nc -nv 10.77.0.3 1524
```

These commands are included for traceability, not as a generalized exploit recipe. They are the exact lab actions documented in the evidence set.

## 21. Team Contributions

- Ajit Mohan: scope control, web exploitation summary, reporting consolidation
- Shamanth R Singh: network exploitation and post-exploitation analysis
- Saiteja Kacham: ML detector work, defender comparison, evasion interpretation
- Madhurjya Deka: remediation framing, executive impact language, presentation support

## 22. Conclusion

The RedScope capstone successfully demonstrated a complete lab-only attack narrative. The environment contained enough weaknesses to support recon, web exploitation, network exploitation, post-exploitation enumeration, and an adversarial-ML exercise. The most important technical result is that the attack chain was not dependent on a single flaw. Multiple flaws existed at once, and they combined into a much more serious exposure.

The practical lesson for defenders is direct. Secure input handling, restricted exposure, proper service hygiene, and layered detection matter more than any isolated control. The practical lesson for the ML portion is equally direct. Small detectors can be evaded, and even improved detectors need broad data and realistic evaluation before anyone trusts them.
