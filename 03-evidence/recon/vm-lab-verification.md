# VM Lab Verification

Date: 2026-06-27

## Running VMs

```text
"Capstone-Kali" {2d3fe7ce-8054-4733-8b17-763b6929d1a2}
"Capstone-Metasploitable2" {fd9eed03-d85b-4ac5-a890-697515af2492}
```

## Kali Interfaces

```text
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24
eth1             UP             10.77.0.4/24
```

## Lab Discovery

```text
10.77.0.1 up
10.77.0.2 up
10.77.0.3 up
10.77.0.4 up
```

`10.77.0.3` matches the Metasploitable VM MAC address.

## Metasploitable Service Check

```text
21/tcp   open   ftp           vsftpd 2.3.4
22/tcp   open   ssh           OpenSSH 4.7p1 Debian 8ubuntu1
23/tcp   open   telnet        Linux telnetd
25/tcp   open   smtp          Postfix smtpd
53/tcp   open   domain        ISC BIND 9.4.2
80/tcp   open   http          Apache httpd 2.2.8
111/tcp  open   rpcbind
139/tcp  open   netbios-ssn   Samba smbd 3.X - 4.X
445/tcp  open   netbios-ssn   Samba smbd 3.X - 4.X
3306/tcp open   mysql         MySQL 5.0.51a
5900/tcp open   vnc           VNC
```

## Docker Web App Reachability From Kali

```text
http://192.169.1.29:3000 -> HTTP/1.1 200 OK
http://192.169.1.29:8080 -> HTTP/1.1 302 Found, Location: login.php
```
