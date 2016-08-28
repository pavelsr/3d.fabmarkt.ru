#!/bin/bash
openssl genrsa -out secret.key 2048
openssl req -new -sha256 -key secret.key -out crt.csr
openssl x509 -req -days 365 -in crt.csr -signkey secret.key -out server.crt
openssl x509 -text -noout -in server.crt