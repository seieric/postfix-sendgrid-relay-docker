# Postfix SendGrid relay Docker

🐳Dockerized postfix which relays emails to SendGrid. Just adding some environment variables, you can setup the container.

<b>Note: This image is made for send-only mail server.</b>

## Features
- 📩 Realy emails to SendGrid
- 🔐 SMTP AUTH (with automated account creation)
- 📇 Sender Canonical
- ✅ SMTP AUTH with LDAP

## How to use
Just pull the image and run the container with environment variables. 

You need to provide the hostname of the container to give the postfix hostname, otherwise it uses the container ID as a hostname.

For example,
```bash
docker run -d --hostname example.com -e SENDGRID_API_KEY=YOUR_API_KEY -e SMTP_USER=user -e SMTP_PASSWORD=abcdef -p 25:25 -p 587:587 ghcr.io/seieric/postfix-sendgrid-relay-docker:latest
```

## Environment variables
#### SENDGRID_API_KEY (Required)
Your SENDGRID's API key. The container wouldn't start if not set.

## Environment variables for SMTP AUTH
If none of the following variables are set, you can use only port 25.
### Basic (single account)
Just create a single account with SMTP_USER and SMTP_PASSWORD.
#### SMTP_USER (Required)
User for SMTP AUTH. If not set, you cannot use submission port 587. Must be used with SMTP_PASSWORD.

#### SMTP_PASSWORD (Required)
Password for SMTP AUTH. If not set, you cannot use submission port 587. Must be used with SMTP_USER.

### LDAP authentication
Use LDAP authentication for SMTP AUTH. You need to set the following variables.

<b>If you configure LDAP authentication, SMTP_USER and SMTP_PASSWORD will be ignored.</b>

#### LDAP_SERVER (Required)
LDAP server address. For example, ```ldap://127.0.0.1``` or ```ldaps://ldap.example.com```.
You can set multiple servers.

#### LDAP_BIND_DN (Required)
LDAP bind DN.

#### LDAP_BIND_PW (Required)
LDAP bind password.

#### LDAP_SEARCH_BASE (Required)
LDAP search base. For example, ```ou=accounts,dc=example,dc=com```.

#### LDAP_SEARCH_FILTER (Optional)
LDAP search filter. Default is  ```(&(objectClass=inetOrgPerson)(uid=%U))```.

## Feature: sender canonical
This image supports sender canonical feature included in postfix.

To use this feature, just mount your sender canonical file to ```/etc/postfix/sender_canonical```
The startup script automatically detects the file and enable the feature.