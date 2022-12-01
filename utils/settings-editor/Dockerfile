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

COPY www/index.html /var/www/localhost/htdocs/index.html
COPY www/schema.js /var/www/localhost/htdocs/schema.js

RUN chmod -r 644 /var/www/localhost/htdocs

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
