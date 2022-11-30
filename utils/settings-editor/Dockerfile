FROM alpine:edge

RUN apk update \
    && apk add lighttpd \
    && rm -rf /var/cache/apk/*

ADD www /var/www/localhost/www

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
