# Merge Notes

This folder combines two roles:

- `00-lab` = the live lab runtime notes and machine state
- `repro-kit` = the portable configuration and reuse docs

The merge keeps the project readable by moving the reusable parts into one place.

## Decision

Use the Docker compose file as the canonical web-app setup.
Keep the VM references as documentation until cleanup is explicitly approved.

## Why this helps

- fewer duplicate instructions
- one folder to hand to another person
- smaller Git-friendly project footprint

## Cleanup rule

Do not delete VM files or folders without explicit permission.

