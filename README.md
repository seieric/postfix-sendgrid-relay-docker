# Postfix SendGrid relay Docker

🐳Dockerized postfix which relays emails to SendGrid. Just adding some environment variables, you can setup the container.

## Features
- 📩 Realy emails to SendGrid
- 🔐 SMTP AUTH (with automated account creation)
- 📇 Sender Canonical
- ✅ SMTP AUTH with LDAP (not implemented yet)

## How to use
Just pull the image and run the container with environment variables.

For example,
```bash
docker run -d --hostname example.com -e SENDGRID_API_KEY=YOUR_API_KEY -e SMTP_USER=user -e SMTP_PASSWORD=abcdef -p 25:25 -p 587:587 ghcr.io/seieric/postfix-sendgrid-relay-docker:main
```

### Environment variables
#### SENDGRID_API_KEY (Required)
Your SENDGRID's API key. The container wouldn't start if not set.

#### SMTP_USER (Optional)
User for SMTP AUTH. If not set, you cannot use submission port 587. Must be used with SMTP_PASSWORD.

#### SMTP_PASSWORD (Optional)
Password for SMTP AUTH. If not set, you cannot use submission port 587. Must be used with SMTP_USER.

### Feature: sender canonical
This image supports sender canonical feature included in postfix.

To use this feature, just mount your sender canonical file to ```/etc/postfix/sender_canonical```
The startup script automatically detects the file and enable the feature.