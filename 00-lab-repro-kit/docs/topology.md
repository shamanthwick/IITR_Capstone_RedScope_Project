# Lab Topology

This lab uses a small hybrid layout:

- Windows host
- Docker containers for DVWA and Juice Shop
- Kali VM as the attacker machine
- Metasploitable 2 VM as the vulnerable target
- Vagrant and Ansible as the reproducible setup layer

## Address plan

- DVWA: `localhost:8080`
- Juice Shop: `localhost:3000`
- Kali lab IP: `10.77.0.4`
- Metasploitable 2: `10.77.0.3`

## Design choice

The Docker services are the small, reusable part of the lab.
The VMs are the heavier local state and should only be removed after approval.
The Ansible files are placeholders for safe provisioning logic and can be expanded if you want a more automated rebuild.

