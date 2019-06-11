
FROM golang:latest
#
RUN \
  apt-get update \
  && apt-get -y install gettext-base runit \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /sites/go/files/templates/

COPY templates/index.html.template /tmp/index.html.template

COPY templates/main.go.template /tmp/main.go.template

RUN mkdir -p /etc/service/go

ADD services/go.service /etc/service/go/run
RUN chmod a+x /etc/service/go/run

ADD scripts/go-start.sh /
RUN chmod u+x /go-start.sh

CMD ["/go-start.sh"]
