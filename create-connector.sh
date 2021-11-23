#!/bin/sh

curl \
  --connect-timeout 5 \
  --max-time 10 \
  --retry 5 \
  --retry-delay 0 \
  --retry-max-time 40 \
  -i -X POST \
  -H "Accept:application/json" \
  -H  "Content-Type:application/json" \
  http://connect:8083/connectors/ \
  -d @debezium-connector.json