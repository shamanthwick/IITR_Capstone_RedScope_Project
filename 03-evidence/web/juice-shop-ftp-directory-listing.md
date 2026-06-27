# Juice Shop FTP Directory Listing PoC

Date: `2026-06-28`

## Target

- `http://localhost:3000/ftp`

## Execution

```powershell
Invoke-WebRequest 'http://localhost:3000/ftp' | Select-Object -ExpandProperty Content
Invoke-WebRequest 'http://localhost:3000/ftp/legal.md' | Select-Object -ExpandProperty Content
```

## Result

- The `/ftp` route returned a browsable directory listing.
- The listing exposed files such as `legal.md`, `incident-support.kdbx`, `announcement_encrypted.md`, and backup files.
- `ftp/legal.md` returned readable content directly.

## Impact

The Juice Shop lab exposes a confidential document directory through direct web access. This demonstrates information disclosure and weak access control on a public application route.
