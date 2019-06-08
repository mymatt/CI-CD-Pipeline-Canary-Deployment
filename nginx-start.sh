#!/bin/bash

envsubst < /tmp/nginx.conf.ctmpl.template > /etc/nginx/nginx.conf.ctmpl
exec /usr/bin/runsvdir /etc/service
