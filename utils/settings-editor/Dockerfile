FROM alpine:edge

RUN apk update \
    && apk add lighttpd \
    && rm -rf /var/cache/apk/*

ADD https://unpkg.com/spectre.css/dist/spectre.min.css /var/www/localhost/htdocs/spectre.min.css
ADD https://unpkg.com/spectre.css/dist/spectre-exp.min.css /var/www/localhost/htdocs/spectre-exp.min.css
ADD https://unpkg.com/spectre.css/dist/spectre-icons.min.css /var/www/localhost/htdocs/spectre-icons.min.css
ADD https://cdn.jsdelivr.net/npm/@json-editor/json-editor@latest/dist/css/jsoneditor.min.css /var/www/localhost/htdocs/jsoneditor.min.css
ADD https://cdn.jsdelivr.net/npm/@json-editor/json-editor@latest/dist/jsoneditor.min.js /var/www/localhost/htdocs/jsoneditor.min.js
ADD https://cdn.jsdelivr.net/npm/js-yaml@4/dist/js-yaml.min.js /var/www/localhost/htdocs/js-yaml.min.js

COPY settings-editor/www/index.html /var/www/localhost/htdocs/index.html
COPY settings-validator/schema.json /var/www/localhost/htdocs/schema.js #FIXME

RUN chmod -R 644 /var/www/localhost/htdocs && chmod 755 /var/www/localhost/htdocs

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
