#! /bin/bash

clear

echo "Starting Verification of Property MAY on FACPL Policy anon_proxy_https"

#Alias z3 is assumed defined in the environment

z3 -st -smt2 Property_MAY_anon_proxy_https.smt2
