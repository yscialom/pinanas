FROM python:3.9-alpine

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
    docker-cli \
    openssl-dev \
    build-base \
    rust \
    cargo

RUN mkdir -m 777 /pinanas-config

# Setup user & group
RUN getent group ${PGID} >/dev/null || addgroup -g ${PGID} docker                        # create group if necessary
RUN getent passwd ${PUID} >/dev/null || adduser -u ${PUID} -D pinanas                    # create user if necessary
RUN adduser $(getent passwd ${PUID} | cut -d: -f1) $(getent group ${PGID} | cut -d: -f1) # add user to group
USER ${PUID}:${PGID}

# Add and run configure
ADD configure-logging.sh /configure-logging.sh
ADD configure-guest.sh /configure-guest.sh
ENTRYPOINT ["/bin/sh", "/configure-guest.sh"]
