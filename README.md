<div align="center">

# RedScope Capstone Project

Lab-only red-team assessment for web exploitation, network compromise, post-exploitation, and adversarial-ML testing.

GitHub repository: [IITR_Capstone_RedScope_Project](https://github.com/shamanthwick/IITR_Capstone_RedScope_Project)

</div>

---

## At A Glance

| Field | Value |
| --- | --- |
| Project type | Security capstone / red-team lab |
| Web targets | DVWA, OWASP Juice Shop |
| Network target | Metasploitable 2 |
| Defensive track | Toy adversarial-ML detector and evasion test |
| Output | Reports, evidence, walkthrough, presentation |
| Scope | Lab-only, controlled, reproducible |

## Project Flow

```text
Planning
   -> Reconnaissance
   -> Scanning
   -> Web / Network Exploitation
   -> Post-Exploitation
   -> ML Detector + Evasion
   -> Reporting
   -> Presentation
```

## What This Project Covers

<table>
  <tr>
    <td valign="top">
      <strong>Offensive Lab Work</strong><br><br>
      Web testing against DVWA and Juice Shop<br>
      Network/service compromise against Metasploitable 2<br>
      Controlled post-exploitation enumeration<br>
      ATT&CK-style attack narrative
    </td>
    <td valign="top">
      <strong>Defensive / AI Work</strong><br><br>
      Toy request classifier<br>
      Adversarial evasion example<br>
      Defender comparison<br>
      Explanation of why the evasion works
    </td>
  </tr>
</table>

## Main Entry Point

The reproducible lab setup is contained in:

- [00-lab-repro-kit](./00-lab-repro-kit)

That folder is the source of truth for rebuilding the lab from configuration, scripts, and documentation.

## Repository Map

| Folder | Purpose |
| --- | --- |
| `00-lab-repro-kit/` | Self-contained lab setup and bootstrap workflow |
| `01-planning/` | Authorization, scope, and rules of engagement |
| `02-recon/` | Discovery notes and inventory |
| `03-evidence/` | Exploit and validation evidence |
| `04-findings/` | Findings register and severity tracking |
| `05-ml-detector/` | Detector and evasion work |
| `06-reports/` | Executive and technical reports |
| `07-presentation/` | Debrief outline and slide structure |
| `08-walkthrough/` | Walkthrough PDF and DOCX |

## Final Deliverables

- signed Rules of Engagement
- attack timeline with ATT&CK technique tags
- reproducible web and network proof-of-concepts
- adversarial-ML detector, evasion result, and comparison
- executive report
- technical report
- presentation / red-team debrief

## Team

| Member | Role Focus |
| --- | --- |
| Shamanth R Singh | Scope, web exploit summary, overall coordination |
| Ajith Mohan | Network foothold and post-exploitation |
| Saiteja Kacham | ML detector and evasion work |
| Madhurjya Deka | Remediation and business impact |

## Safety Notes

- Only test the lab systems.
- Do not expose the targets to public networks.
- Do not commit VM images, snapshots, installers, or secrets.
- Keep machine-specific runtime state outside of Git.

## Useful Links

- [Executive report](./06-reports/executive-report.md)
- [Technical report](./06-reports/technical-report.md)
- [Debrief outline](./07-presentation/outline.md)
- [Walkthrough PDF](./08-walkthrough/RedScope_Project_Walkthrough.pdf)

---

If you want the deck and reports to line up exactly, keep the README narrative in the same order as the project flow above.
