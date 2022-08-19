FROM ubuntu:22.04

RUN echo "postfix postfix/mailname string localhost.localdomain" && echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections && \
    apt-get update && apt-get -y install postfix libsasl2-modules && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

COPY configs/main.cf /etc/postfix/
COPY configs/master.cf /etc/postfix/
COPY --chmod=700 init-postfix.sh /

EXPOSE 25
EXPOSE 587

ENTRYPOINT ["/init-postfix.sh"]