#!/bin/bash

mkdir https
cd https
openssl genrsa -out key.pem 2048
openssl req -new -sha256 -key key.pem -out crt.pem