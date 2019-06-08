
FROM consul:latest

COPY templates/config.json.client /tmp/config.json.client

# generate consul config file from ENV variables defined in docker-compose using envsubst
# run consul client
CMD ["/bin/bash", "-c", "envsubst < /tmp/config.json.cliente > /consul/config/config.json && /usr/local/bin/consul agent -bind -retry-join="]
