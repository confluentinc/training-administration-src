#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose
#    -o xtrace

# Cleanup files
find . \( -type f -name "*.crt" -o -name "*.csr" -o -name "*_creds" -o -name "*.jks" -o -name "*.srl" -o -name "*.key" -o -name "*.pem" -o -name "*.der" -o -name "*.p12" \)  -delete

# Generate CA key
openssl req -new -x509 -keyout ca.key -out ca.crt -days 365 -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US' -passin pass:confluent -passout pass:confluent


for i in kafka-1 kafka-2 kafka-3 client
do
	echo "------------------------------- $i -------------------------------"

	# Create host keystore
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i,OU=TEST,O=CONFLUENT,L=PaloAlto,S=Ca,C=US" \
                                 -ext san=dns:$i \
				 -keystore $i-creds/kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass confluent \
				 -keypass confluent

	# Create the certificate signing request (CSR)
	keytool -keystore $i-creds/kafka.$i.keystore.jks -alias $i -certreq -file $i-creds/$i.csr -storepass confluent -keypass confluent

        # Sign the host certificate with the certificate authority (CA)
	openssl x509 -req -CA ca.crt -CAkey ca.key -in $i-creds/$i.csr -out $i-creds/$i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:confluent

        # Sign and import the CA cert into the keystore
	keytool -noprompt -keystore $i-creds/kafka.$i.keystore.jks -alias CARoot -import -file ca.crt -storepass confluent -keypass confluent

        # Sign and import the host certificate into the keystore
	keytool -noprompt -keystore $i-creds/kafka.$i.keystore.jks -alias $i -import -file $i-creds/$i-ca1-signed.crt -storepass confluent -keypass confluent

	# Create truststore and import the CA cert
	keytool -noprompt -keystore $i-creds/kafka.$i.truststore.jks -alias CARoot -import -file ca.crt -storepass confluent -keypass confluent

	# Save creds
  	echo "confluent" > ${i}-creds/${i}_sslkey_creds
  	echo "confluent" > ${i}-creds/${i}_keystore_creds
  	echo "confluent" > ${i}-creds/${i}_truststore_creds

	# Create pem files and keys used for Schema Registry HTTPS testing
	#   openssl x509 -noout -modulus -in client.certificate.pem | openssl md5
	#   openssl rsa -noout -modulus -in client.key | openssl md5 
        #   echo "GET /" | openssl s_client -connect localhost:8082/subjects -cert client.certificate.pem -key client.key -tls1 
	keytool -export -alias $i -file $i-creds/$i.der -keystore $i-creds/kafka.$i.keystore.jks -storepass confluent
	openssl x509 -inform der -in $i-creds/$i.der -out $i-creds/$i.certificate.pem
	keytool -importkeystore -srckeystore $i-creds/kafka.$i.keystore.jks -destkeystore $i-creds/$i.keystore.p12 -deststoretype PKCS12 -deststorepass confluent -srcstorepass confluent -noprompt
	openssl pkcs12 -in $i-creds/$i.keystore.p12 -nodes -nocerts -out $i-creds/$i.key -passin pass:confluent

done
