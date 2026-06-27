# Reuse Notes

This project is intended to be GitHub-friendly and rebuildable from configuration.

Commit:

- `docker-compose.yml`
- `Vagrantfile`
- `ansible/*.yml`
- scripts
- documentation

Do not commit:

- VM disk files
- ISO files
- snapshots
- installers
- secrets

If you want a clean rebuild later, run:

```powershell
.\scripts\bootstrap-lab.ps1
```

This matches the IaC pattern: share the instructions and automation, not the heavy VM artifacts. The bootstrap script is the single entry point for the full lab.
