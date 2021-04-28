#!/bin/bash

domain=nextcloud.local

# generate here
cd $(dirname $0)

# password file
echo -n "Cerificate password: "
read -s password
echo
echo -n "${password}" > "${domain}-key.pass"

# self-signed
openssl req -x509 -newkey rsa:4096  -days 365 \
        -keyout "${domain}-key.pem" -passout "file:${domain}-key.pass" \
        -out "${domain}.pem" -passout "file:${domain}-key.pass"

# read protection
chmod 600 *.pem *.pass
