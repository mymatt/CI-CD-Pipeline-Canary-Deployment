#!/bin/bash

envsubst < /tmp/index.html.template > /sites/go/files/templates/index.html
envsubst < /tmp/main.go.template > /sites/go/files/main.go
exec /usr/bin/runsvdir /etc/service
