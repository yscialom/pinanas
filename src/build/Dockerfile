FROM python:3-alpine

ARG PUID
ARG PGID

ENV PINANAS_SRC  /pinanas/src
ENV PINANAS_DIST /pinanas/dist
ENV PINANAS_VENV /pinanas/venv

# Install dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    docker-cli

RUN mkdir -m 777 /pinanas-config

# Setup user
RUN addgroup -g ${PGID} docker \
    && adduser -u ${PUID} -D -G docker pinanas
USER pinanas

# Add and run configure
ADD configure-logging.sh /configure-logging.sh
ADD configure-guest.sh /configure-guest.sh
CMD sh /configure-guest.sh
