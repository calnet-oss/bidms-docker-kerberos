#!/bin/bash

CONTAINER_DIR="/v1"
INSPECT=$(docker inspect bidms-kerberos | sed -e '/Source/,/Destination/!d')

while read -ra arr; do
  if [ "${arr[0]}" == '"Source":' ]; then
    src=${arr[1]}
  elif [[ "${arr[0]}" == '"Destination":' && "${arr[1]}" == "\"$CONTAINER_DIR\"," ]]; then
    kerberos_src=$src
  fi
done  <<< "$INSPECT"
kerberos_src=$(echo $kerberos_src|cut -d'"' -f2)

echo $kerberos_src
