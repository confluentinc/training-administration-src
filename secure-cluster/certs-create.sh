#! /bin/sh
#
# SPDX-FileCopyrightText: Copyright (c) 2019-2025 Confluent Inc.
# SPDX-License-Identifier: Apache-2.0
#

# Script safety options
set -o errexit
set -o nounset
# Set pipefail if it works in a subshell, disregard if unsupported
# shellcheck disable=SC3040
(set -o pipefail 2> /dev/null) && set -o pipefail

# Set up some local variables
CONF_DIR="$HOME/confluent-admin/secure-cluster"
TRUSTSTORE="$CONF_DIR/truststore.jks"
CRED="confluent"

# Cleanup files
rm -f "$CONF_DIR"/*-creds/* "$CONF_DIR"/ca.??? "$CONF_DIR"/truststore.jks

# Generate CA key
openssl req -new -x509 -keyout ca.key -out ca.crt -days 365 -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=MountainView/ST=CA/C=US' -passin pass:confluent -passout pass:confluent

# Create a truststore with the CA
keytool -noprompt -keystore "$TRUSTSTORE" -alias CARoot -import -file ca.crt -storepass ${CRED}

for i in kafka-1 kafka-2 kafka-3 client
do
	echo "------------------------------- $i -------------------------------"
	WORKDIR="$CONF_DIR/$i-creds"
	KEYSTORE="$WORKDIR/kafka.$i.keystore.jks"
	CS_REQUEST="$WORKDIR/$i.csr"
	CERT_FILE="$WORKDIR/$i-ca1-signed.crt"

	# Create host keystore
	keytool -genkey -noprompt \
    -alias "$i" \
    -dname "CN=$i,OU=TEST,O=CONFLUENT,L=MountainView,ST=CA,C=US" \
    -ext "san=dns:$i" \
    -keystore "$KEYSTORE" \
    -keyalg RSA \
    -storepass ${CRED} \
    -keypass ${CRED}

	# Create the certificate signing request (CSR)
	keytool -keystore "$KEYSTORE" -alias $i -certreq -file "$CS_REQUEST" -storepass ${CRED} -keypass ${CRED}

	# Sign the host certificate with the certificate authority (CA)
	openssl x509 -req -CA ca.crt -CAkey ca.key -in "$CS_REQUEST" -out "$CERT_FILE" -days 9999 -CAcreateserial -passin pass:${CRED}

	# Sign and import the CA cert into the keystore
	keytool -noprompt -keystore "$KEYSTORE" -alias CARoot -import -file ca.crt -storepass ${CRED}
	# -keypass ${CRED}

	# Sign and import the host certificate into the keystore
	keytool -noprompt -keystore "$KEYSTORE" -alias $i -import -file "$CERT_FILE" -storepass ${CRED} -keypass ${CRED}

	# Copy the truststore inside so it will be visible inside the Broker's container
	cp "$TRUSTSTORE" "$WORKDIR/kafka.$i.truststore.jks"

	# Save JKS credentials
	echo ${CRED} > "$WORKDIR/${i}_sslkey_creds"
	ln "$WORKDIR/${i}_sslkey_creds" "$WORKDIR/${i}_keystore_creds"
	ln "$WORKDIR/${i}_sslkey_creds" "$WORKDIR/${i}_truststore_creds"

done

echo "Waiting for brokers to become available ..."
while ! echo "q" | openssl s_client -connect kafka-1:19093 -tls1_3 > /dev/null 2>&1 ; do sleep 2 ; done
echo "Brokers ready"
