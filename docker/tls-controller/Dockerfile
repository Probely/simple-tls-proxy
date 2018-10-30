FROM alpine:latest

RUN apk --no-cache add certbot python3 && \
	mkdir -p /tls-controller/bin && \
	mkdir -p /tls-controller/var/config

ADD src/controller.py /tls-controller/bin/controller
ADD src/templates /tls-controller/templates/

CMD ["/tls-controller/bin/controller"] 
RUN chmod +x /tls-controller/bin/*
