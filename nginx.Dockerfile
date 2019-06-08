
FROM nginx:latest

RUN \
  apt-get update \
  && apt-get -y install apache2-utils curl unzip runit \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV CT_VERSION=0.19.5

ENV CONSUL_T_PACKAGE=https://releases.hashicorp.com/consul-template/${CT_VERSION}/consul-template_${CT_VERSION}_linux_amd64.zip

ADD ${CONSUL_T_PACKAGE} /tmp/

RUN unzip /tmp/consul-template_${CT_VERSION}_linux_amd64.zip -d /usr/local/bin/; rm /tmp/consul-template_${CT_VERSION}_linux_amd64.zip; chmod +x /usr/local/bin/consul-template;

# consul-template -template="all-services.tpl:all-services.txt" -once
COPY templates/all-services.tpl /tmp/all-services.tpl

COPY templates/nginx.conf.ctmpl.template /tmp/nginx.conf.ctmpl.template

COPY templates/nginx.consul-template.hcl /etc/nginx/nginx.consul-template.hcl

RUN mkdir -p /etc/service/nginx && rm -rf /etc/service/nginx/* && mkdir -p /etc/service/consul-template && rm -rf /etc/service/consul-template/*

ADD services/nginx.service /etc/service/nginx/run
RUN chmod a+x /etc/service/nginx/run
ADD services/consul-template.service /etc/service/consul-template/run
RUN chmod a+x /etc/service/consul-template/run

ADD scripts/nginx-start.sh /
RUN chmod u+x /nginx-start.sh

CMD ["/nginx-start.sh"]
