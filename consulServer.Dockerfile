
FROM consul:latest

# envsubst requires gettext
RUN \
  apk update \
  && apk add gettext \
  && rm -rf /var/cache/apk/*

RUN echo "127.0.0.1  consul consul" >> /etc/hosts

COPY templates/config.json.server /tmp/config.json.server

# generate consul config file from ENV variables defined in docker-compose using envsubst
# run consul server
CMD ["/bin/sh", "-c", "envsubst < /tmp/config.json.server > /consul/config/config.json && consul agent -config-dir=/consul/config/"]
