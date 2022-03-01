#!/bin/sh
PINANAS_SRC="$(dirname "$(readlink -f "${0}")")"
PINANAS_DIST="$(readlink -f "${PWD}")"
PINANAS_VENV="${PINANAS_DIST}/.venv"

. ${PINANAS_SRC}/build/configure-logging.sh

configure () {
    local tag=pinanas-config:latest
    docker build \
        --rm \
        -t ${tag} \
        --build-arg PUID=$(id -u) \
        --build-arg PGID=$(stat -c %g /var/run/docker.sock) \
        "${PINANAS_SRC}"/build
    mkdir -p "${PINANAS_VENV}"
    trap "docker volume rm pinanas-config" EXIT
    docker volume create pinanas-config >/dev/null # used for inter-container communication
    docker run \
        --rm \
        -e PINANAS_SRC="${PINANAS_SRC}" \
        -e PINANAS_DIST="${PINANAS_DIST}" \
        -e PINANAS_VENV="${PINANAS_VENV}" \
        -v pinanas-config:/pinanas-config \
        -v "${PINANAS_SRC}":/pinanas/src:ro \
        -v "${PINANAS_DIST}":/pinanas/dist \
        -v "${PINANAS_VENV}":/pinanas/venv \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ${tag}

}

report () {
    info "Configuration successful."
    cont "You can clean work files with ./distclean.sh"
    cont "Start your services with docker-compose up -d"

    command -v netstat >/dev/null || return
    if netstat -lan | grep -qE ':53\W' ; then
        warn "Port udp/53 appears to be already in use. You should free it before starting pinanas."
        cont "On Ubuntu 18.04+ systems, in order to free udp/53 you can disable your local DNS cache server:"
        cont "    sudo mkdir -p /etc/systemd/resolved.conf.d"
        cont "    echo -e '[Resolve]\nDNSStubListener=no' | sudo tee -a /etc/systemd/resolved.conf.d/disable-for-pinanas.conf"
        cont "    sudo systemctl force-reload systemd-resolved"
        cont "    sudo rm /etc/resolv.conf"
        cont "    sudo ln -s ../run/systemd/resolve/resolv.conf /etc/resolv.conf"
    fi
}

configure
report
