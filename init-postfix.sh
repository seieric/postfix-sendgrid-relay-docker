#!/bin/bash
if [[ -z $SENDGRID_API_KEY ]]; then
  echo "You need to set SENDGRID_API_KEY to the container." >&2
  exit -1
fi

echo "[smtp.sendgrid.net]:587 apikey:$SENDGRID_API_KEY" >> /etc/postfix/sasl_passwd

# create user
if [[ -n $SMTP_USER ]] && [[ -n $SMTP_PASSWORD ]]; then
  echo $SMTP_PASSWORD | saslpasswd2 -p $SMTP_USER
fi

/usr/sbin/postmap /etc/postfix/sasl_passwd && rm /etc/postfix/sasl_passwd && chmod 600 /etc/postfix/sasl_passwd.db && \
/usr/sbin/postfix start
/usr/sbin/saslauthd -a sasldb
# prevent exit
tail -f /dev/null