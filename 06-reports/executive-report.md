# Executive Report

## Project

RedScope Capstone Red-Team Assessment

## Team

- Shamanth R Singh
- Ajith Mohan
- Saiteja Kacham
- Madhurjya Deka

## Purpose

This report summarizes a controlled security assessment of an intentionally vulnerable lab environment built from DVWA, OWASP Juice Shop, and a Metasploitable-like Linux VM. The goal was not to attack real systems. The goal was to show, in a safe lab, how a realistic attack chain can start from recon, move through a web weakness, gain a network foothold, continue into post-exploitation, and then test whether a simple ML-based detector can be fooled.

The document is written for a non-technical audience. It explains what was tested, why it matters to a business, what was proven in the lab, and what should be fixed first.

## Bottom Line

The assessment demonstrated that a small number of exposed weaknesses can combine into a full compromise path:

1. A weak web input path in DVWA allowed SQL injection in the lab.
2. Juice Shop exposed a browsable `/ftp` directory with confidential-looking files.
3. The Metasploitable VM exposed a root bind shell with no authentication.
4. A toy ML detector could be bypassed by a modified attack sample, while a slightly stronger character n-gram defender reduced that evasion but still showed the limits of a small dataset.

In plain terms: one weak web control and one exposed service were enough to show how an attacker could move from initial access to deeper compromise. The lab is intentionally vulnerable, but the lesson is real. Security depends on layered controls, not a single gate.

## Scope

Only the lab systems were tested. The in-scope assets were:

- DVWA at `http://localhost:8080`
- OWASP Juice Shop at `http://localhost:3000`
- Metasploitable-like VM at `10.77.0.3`

No public systems were targeted. No denial-of-service activity was performed. No real data was exfiltrated. All activity stayed inside the lab rules of engagement.

## What We Tested

The team carried out four main activities:

- Web testing against DVWA
- Web testing against Juice Shop
- Network exploitation against Metasploitable
- A small ML detector experiment to test evasion behavior

The tests were selected because they represent common real-world failure modes:

- untrusted input reaching a database
- direct exposure of sensitive web content
- legacy services left open on an internal host
- model-based detection that relies too heavily on limited features

## What We Found

### Web risk in DVWA

The DVWA SQL injection path accepted unsanitized input and returned more data than intended. In business terms, that is a data exposure problem. If the same flaw existed in a real application, it could expose customer records, internal account data, or administrative functions.

### Web risk in Juice Shop

Juice Shop exposed a browsable `/ftp` route that listed files directly in the browser. That is an access-control issue. It is not as dramatic as a full system compromise, but it still leaks information that an attacker can use to plan further activity.

### Network risk in Metasploitable

The Metasploitable host exposed a bind shell that returned root-level access without authentication. That is a direct compromise condition. In a real environment, this would mean an attacker already had complete control of the system.

### ML risk

The baseline detector worked only partially. It could be evaded by a modified payload in the toy test set. A second defender based on character n-grams was more resistant to the demonstrated evasion, but still imperfect. The lesson is not that ML is useless. The lesson is that small models trained on narrow examples are easy to confuse and must be paired with other controls.

## Business Impact

If these issues were present in a real company environment, the consequences would be serious:

- sensitive data could be exposed
- internal documents could be discovered
- an attacker could gain full control of a server
- incident response time would increase
- trust, compliance posture, and operational continuity could be damaged

The most important point is that attacks usually do not happen in one step. A weak page, an exposed directory, and a forgotten service can combine into a chain that is much more damaging than any single issue on its own.

## Attack Narrative

### Phase 1: Reconnaissance

The team mapped the lab and identified the exposed web applications and legacy network services. This established the attack surface and confirmed that the lab was set up correctly.

### Phase 2: Web compromise

DVWA produced a clean SQL injection proof of concept after the database was reset to the documented lab state. This validated the classic risk of unsafely handled input.

### Phase 3: Additional exposure

Juice Shop exposed the `/ftp` directory and its contents through normal web requests. That showed how data that should have remained internal can become publicly readable.

### Phase 4: Network foothold

The Metasploitable bind shell returned root access directly. That proved the network side of the lab had a severe exposure that would allow full takeover.

### Phase 5: Post-exploitation and analysis

After access, the team performed limited enumeration to understand what a successful attacker could see. The activity stayed inside the lab and was used only to document impact.

### Phase 6: ML evasion study

A simple baseline detector was built, then a modified payload was used to test whether the detector would misclassify the request. A second defender reduced the success of that evasion. This is useful because it shows how a defender can improve and where the weaknesses remain.

## Risk Summary

| Severity | Count | Meaning |
| --- | ---: | --- |
| Critical | 1 | Direct root compromise on a lab host |
| High | 3 | Strong compromise or sensitive-function exposure |
| Medium | 6 | Meaningful weakness with constraints |
| Low | 0 | None recorded in the final register |

The most important items are the critical bind shell, the DVWA SQL injection, and the Juice Shop directory exposure. The remaining findings support the attack path and show that the environment had multiple stacked weaknesses.

## Key Recommendations

### 1. Remove exposed services and reduce attack surface

Disable any service that is not required for the exercise. In a real environment, that means especially avoiding legacy services and direct shells exposed to the network.

### 2. Enforce secure web input handling

Validate and parameterize all database access. Prevent raw user input from being inserted into queries.

### 3. Lock down sensitive directories

Do not expose confidential content through browsable HTTP directories. Apply access control and remove sensitive files from public paths.

### 4. Improve detection quality

Use ML only as one layer of defense. Train on broader data, test against obfuscation, and pair model output with rule-based and behavioral controls.

### 5. Maintain operational discipline

Keep rules of engagement, logs, and evidence trails for every test. The project showed that disciplined documentation makes the results easier to trust and present.

## Team Roles

- Shamanth R Singh: scope, lab coordination, web exploitation summary, final consolidation
- Ajith Mohan: network foothold, post-exploitation summary, ATT&CK mapping
- Saiteja Kacham: ML detector work, evasion testing, defender comparison
- Madhurjya Deka: remediation framing, business impact, and presentation support

## Conclusion

The RedScope lab demonstrated the full shape of a real attack chain in a safe environment. The value of the project is not that the lab was broken on purpose. The value is that the team proved how small weaknesses stack together, how an attacker can move from web exposure to system compromise, and why detection must be validated against evasion.

The practical takeaway is simple: reduce exposed services, harden web input paths, protect sensitive content, and treat ML-based detection as one control among several, not a final answer.
