#!/usr/bin/env bash

# Script for modifying weightings of Nginx Load Balancing for v1 and v2, using Consul Keys
# Usage: ./var_kv.sh st=1 v1=5 v2=0

st=start_web
v1=blue_weight
v2=green_weight

while
[[ $# -gt 0 ]]
do
  arr=($(echo $1 | tr "=" "\n"))
  Y=${arr[0]}
  curl -X PUT -d ${arr[1]} http://localhost:8500/v1/kv/prod/${!Y}
  shift
done
