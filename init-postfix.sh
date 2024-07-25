#!/bin/bash
if [[ -z $SENDGRID_API_KEY ]]; then
  echo "You need to set SENDGRID_API_KEY to the container." >&2
  exit -1
fi

echo "[smtp.sendgrid.net]:587 apikey:$SENDGRID_API_KEY" >> /etc/postfix/sasl_passwd

if [[ -n $LDAP_SERVER ]] && [[ $LDAP_BIND_DN ]] && [[ $LDAP_BIND_PW ]] && [[ $LDAP_SEARCH_BASE ]]; then
  echo "Use LDAP authentication. Ignoring SMTP_USER and SMTP_PASSWORD."
  cat << EOF >> /etc/saslauthd.conf
ldap_servers: $LDAP_SERVER
ldap_use_sasl: no
ldap_bind_dn: $LDAP_BIND_DN
ldap_password: $LDAP_BIND_PW
ldap_mech: PLAIN
ldap_auth_method: bind
ldap_filter: ${LDAP_FILTER:-"(&(objectClass=inetOrgPerson)(uid=%U))"}
ldap_scope: sub
ldap_search_base: $LDAP_SEARCH_BASE
ldap_deref: always
EOF
  /usr/sbin/saslauthd -a ldap -O /etc/saslauthd.conf
elif [[ -n $SMTP_USER ]] && [[ -n $SMTP_PASSWORD ]]; then
  echo "Use SMTP_USER and SMTP_PASSWORD"
  echo $SMTP_PASSWORD | saslpasswd2 -p -u localhost.localdomain $SMTP_USER
  /usr/sbin/saslauthd -a sasldb
fi

adduser postfix sasl

if [[ -e /etc/postfix/sender_canonical ]]; then
  /usr/sbin/postmap /etc/postfix/sender_canonical && chmod 600 /etc/postfix/sender_canonical.db
  if grep -q "^sender_canonical_maps" /etc/postfix/main.cf; then
    sed -i 's/^sender_canonical_maps/sender_canonical_maps = hash:\/etc\/postfix\/sender_canonical/' /etc/postfix/main.cf
  else
    echo "sender_canonical_maps = hash:/etc/postfix/sender_canonical" >> /etc/postfix/main.cf
  fi
fi
/usr/sbin/postmap /etc/postfix/sasl_passwd && rm /etc/postfix/sasl_passwd && chmod 600 /etc/postfix/sasl_passwd.db && \
/usr/sbin/postfix start-fg