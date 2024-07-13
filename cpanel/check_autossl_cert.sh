#!/bin/bash

if [[ -z "$1" || "$1" == "-h" ]]; then
    echo "Usage: $0 <acct_domain>" >&2
    exit 1
fi

CLOSE_TO_EXPIRATION_DAYS=30

DOMAIN="$1"
CERT="/var/cpanel/ssl/apache_tls/$DOMAIN/certificates"

if [[ ! -r "$CERT" ]]; then
    echo "Domain \"$DOMAIN\" is not a valid account domain" >&2
    exit 1
fi

EXPIRY_STR="$(openssl x509 -noout -dates -in "$CERT" | grep notAfter | cut -d= -f2)"
EXPIRY_TS="$(date -d "$EXPIRY_STR" +%s)"
DAYS_TO_EXPIRATION="$(( ($EXPIRY_TS - $(date +%s)) / 60 / 60 / 24 ))"

if [[ $DAYS_TO_EXPIRATION -le $CLOSE_TO_EXPIRATION_DAYS ]]; then
    if [[ $DAYS_TO_EXPIRATION == $CLOSE_TO_EXPIRATION_DAYS || $(( $DAYS_TO_EXPIRATION % 4 )) == 0 ]]; then
        echo "Certificate for \"$DOMAIN\" will expire in $DAYS_TO_EXPIRATION days"
        echo
    fi

    exit 1
fi