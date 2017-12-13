#!/bin/bash

source config.sh

CONTAINER=`docker run -it -d -p 8080:$TOMCAT_PORT sunfish:infra /bin/sh`
INFRA_IP=`docker inspect -f '{{ .NetworkSettings.IPAddress }}' $CONTAINER`
SUNFISH_CONF=/usr/local/tomcat/conf/sunfish/

PROXY_HOME=/usr/local/tomcat/


echo "                            *********************************"
echo "                            Welcome to the SUNFISH Installer!"
echo "                            *********************************"
echo
echo "-----------------------------------------------------------------------------------------"
echo "Container $CONTAINER up and running"
echo "set the following IP for the tenant: $INFRA_IP"
read -p "hit return when done"
echo "-----------------------------------------------------------------------------------------"
echo

function createPAPConf {


    echo "ri = $PAP_URL_RI" > pap.config
    docker cp pap.config $CONTAINER:$SUNFISH_CONF
    echo "PAP Config"
}


function createPDPConf {

    echo "prps = $PDP_URLS_PRPS" > pdp.config
    echo "pips = $PDP_URLS_PIPS" >> pdp.config
    docker cp pdp.config $CONTAINER:$SUNFISH_CONF
    echo "PDP Config"
}

function createPRPConf {
    

    echo "maxThreads = $PRP_MAX_THREADS" > prp.config
    echo "maxPolicyCount = $PRP_MAX_POLICY_COUNT" >> prp.config
    echo "ri = $PRP_URL_RI" >> prp.config
    docker cp prp.config $CONTAINER:$SUNFISH_CONF

    echo "PRP Config"
}

function copyPIPAttributes {

    docker cp attributes $CONTAINER:$SUNFISH_CONF/pip

    echo "PIP Attributes"
}

function createPIPDatabase {

    for entry in "${!PIP_DATABASE[@]}"; do echo "$entry = ${PIP_DATABASE[$entry]}" >> pip_database.config; done
    
    docker cp pip_database.config $CONTAINER:$SUNFISH_CONF/pip/database

}


function createRIConf {

    echo "rootPolicy.dir = $SUNFISH_CONF/ri" >> ri.config
    docker exec $CONTAINER mkdir /usr/local/tomcat/conf/sunfish/ri
    docker cp ri.config $CONTAINER:$SUNFISH_CONF/ri.config
    

}

function copyProxyFilter {

    docker cp dependencies/ProxyFilter-0.0.1-SNAPSHOT.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/commons-io-1.3.2.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/json-20170516.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/json-simple-1.1.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/httpclient-4.5.3.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/httpcore-4.4.6.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/commons-logging-1.1.1.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/jdom-2.0.2.jar $CONTAINER:$PROXY_HOME/lib
    docker cp dependencies/commons-codec-1.10.jar $CONTAINER:$PROXY_HOME/lib
    docker cp web.xml $CONTAINER:$PROXY_HOME/conf
    docker cp params.json $CONTAINER:$PROXY_HOME/conf
    echo "ProxyFilter setup"
}

createPAPConf
createPDPConf
createPRPConf
createRIConf
copyPIPAttributes
createPIPDatabase
copyProxyFilter

rm pap.config pdp.config pip_database.config prp.config ri.config

docker exec -it $CONTAINER /usr/local/tomcat/bin/catalina.sh run

#docker kill $CONTAINER

