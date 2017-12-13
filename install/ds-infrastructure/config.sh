#!/bin/bash

TOMCAT_PORT=8080

# PAP Config
#**********************************************
PAP_URL_RI="http://localhost:8080/ri/mocked"


# PDP Config
#**********************************************
# All possible PRPs (seperated by comma)
PDP_URLS_PRPS="http://localhost:8080/prp/v1"
# All possible PIPs (seperated by comma)
PDP_URLS_PIPS="http://localhost:8080/pip/v1"


# PRP Config
#**********************************************
PRP_MAX_THREADS=8
PRP_MAX_POLICY_COUNT=1000
PRP_URL_RI="http://localhost:8080/ri/mocked"


# PIP Database
#**********************************************
declare -A PIP_DATABASE
PIP_DATABASE["sample.entry"]="test"
