#!/bin/bash
if [ $# -eq 0 ]
then
    printf "\nNo argument supplied. \nPlease supply version #\n"
    exit 0
fi

printf "\nBuilding images stage $1...\n"
docker build --no-cache -t idp:v$1 --build-arg ISC_PACKAGE_USER_PASSWORD="SYS" --build-arg ISC_PACKAGE_CSPSYSTEM_PASSWORD="SYS" .
docker images 