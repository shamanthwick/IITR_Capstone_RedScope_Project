# Week 1 Recon Raw Evidence

## Host Discovery

Command:

```bash
nmap -sn 10.77.0.0/24
```

Result:

```text
10.77.0.1 up
10.77.0.2 up
10.77.0.3 up
10.77.0.4 up
```

Interpretation:

- `10.77.0.3` is the Metasploitable lab VM.
- `10.77.0.4` is Kali.
- `10.77.0.1` and `10.77.0.2` are VirtualBox NAT Network infrastructure addresses.

## Metasploitable Service Enumeration

Command:

```bash
nmap -sV -sC 10.77.0.3
```

Key results:

```text
21/tcp   open  ftp         vsftpd 2.3.4
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1
23/tcp   open  telnet      Linux telnetd
25/tcp   open  smtp        Postfix smtpd
53/tcp   open  domain      ISC BIND 9.4.2
80/tcp   open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
111/tcp  open  rpcbind
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X
445/tcp  open  netbios-ssn Samba smbd 3.0.20-Debian
512/tcp  open  exec        netkit-rsh rexecd
513/tcp  open  login
1099/tcp open  java-rmi    GNU Classpath grmiregistry
1524/tcp open  bindshell   Metasploitable root shell
2049/tcp open  nfs
2121/tcp open  ftp         ProFTPD 1.3.1
3306/tcp open  mysql       MySQL 5.0.51a-3ubuntu5
5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
5900/tcp open  vnc         VNC
6000/tcp open  X11         access denied
6667/tcp open  irc         UnrealIRCd
8009/tcp open  ajp13       Apache Jserv
8180/tcp open  http        Apache Tomcat/5.5
```

Notable script observations:

```text
Anonymous FTP login allowed.
SMTP supports SSLv2.
SMB message signing disabled.
Apache title: Metasploitable2 - Linux.
Tomcat title: Apache Tomcat/5.5.
```

## Web Fingerprinting

Command:

```bash
whatweb http://192.169.1.29:3000 http://192.169.1.29:8080 http://10.77.0.3
```

Key results:

```text
Juice Shop: OWASP Juice Shop, HTTP 200, HTML5, X-Frame-Options SAMEORIGIN.
DVWA: Apache/2.4.25 Debian, DVWA login page, PHP, cookie security=low.
Metasploitable web: Apache/2.2.8 Ubuntu DAV/2, PHP/5.2.4, title Metasploitable2 - Linux.
```

## Directory Discovery

Metasploitable web:

```text
/dav
/index.php
/phpMyAdmin
/phpinfo.php
/test
/twiki
/server-status -> 403
```

DVWA:

```text
/config
/docs
/external
/favicon.ico
/index.php -> login.php
/php.ini
/phpinfo.php -> login.php
/robots.txt
/server-status -> 403
```

Juice Shop:

```text
/api -> 500
/apis -> 500
/assets
/ftp
/media
/profile -> 500
/promotion
/redirect -> 500
/rest -> 500
/restricted -> 500
/robots.txt
/video
```
