#!/bin/bash
if [[ -z $SENDGRID_API_KEY ]]; then
  echo "You need to set SENDGRID_API_KEY to the container." >&2
  exit -1
fi

echo "[smtp.sendgrid.net]:587 apikey:$SENDGRID_API_KEY" >> /etc/postfix/sasl_passwd

# create user
if [[ -n $SMTP_USER ]] && [[ -n $SMTP_PASSWORD ]]; then
  echo $SMTP_PASSWORD | saslpasswd2 -p -u localhost.localdomain $SMTP_USER
fi

adduser postfix sasl

#cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
if [[ -e /etc/postfix/sender_canonical ]]; then
  /usr/sbin/postmap /etc/postfix/sender_canonical && chmod 600 /etc/postfix/sender_canonical.db
  echo "sender_canonical_maps = hash:/etc/postfix/sender_canonical" >> /etc/postfix/main.cf
fi
/usr/sbin/postmap /etc/postfix/sasl_passwd && rm /etc/postfix/sasl_passwd && chmod 600 /etc/postfix/sasl_passwd.db && \
/usr/sbin/saslauthd -a sasldb
/usr/sbin/postfix start-fg