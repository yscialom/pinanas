#!/bin/sh
PINANAS_SRC="$(dirname "$(dirname "$(readlink -f "${0}")")")"
PINANAS_DIST="$(readlink -f "${PWD}")"
PINANAS_VENV="${PINANAS_DIST}/.venv"

. ${PINANAS_SRC}/install/installer/configure-logging.sh

configure () {
    local tag=pinanas-config
    docker build \
        --rm \
        -t ${tag} \
        --build-arg PUID=$(id -u) \
        --build-arg PGID=$(stat -c %g /var/run/docker.sock) \
        "${PINANAS_SRC}"/install/installer
    mkdir -p "${PINANAS_VENV}"
    trap "docker volume rm pinanas-config" EXIT
    docker volume create pinanas-config >/dev/null # used for inter-container communication
    docker run \
        --rm \
        --net host `# necessary to detect network properties from default settings` \
        -e PINANAS_SRC="${PINANAS_SRC}" \
        -e PINANAS_DIST="${PINANAS_DIST}" \
        -e PINANAS_VENV="${PINANAS_VENV}" \
        -e PIP_CACHE_DIR="${PINANAS_VENV}"/.pip-cache \
        -v pinanas-config:/pinanas-config \
        -v "${PINANAS_SRC}":/pinanas/src:ro \
        -v "${PINANAS_DIST}":/pinanas/dist \
        -v "${PINANAS_VENV}":/pinanas/venv \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ${tag} \
        "$@"
}

export_version () {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1 ; then
        git describe >"${PINANAS_DIST}/VERSION"
        echo "" >>"${PINANAS_DIST}/VERSION"
        ( [ -z "$(git status --porcelain)" ] && echo "Clean working directory" || git status ) >>"${PINANAS_DIST}/VERSION"
    else
        echo "unknown" >"${PINANAS_DIST}/VERSION"
    fi
}

report () {
    info "Configuration successful."
    cont "Start your services with 'docker compose up -d'"
    cont "Optionnally, you can:"
    cont "  - clean work files with './distclean.sh'"
    cont "  - uninstall all with './uninstall.sh'"
    cont "Thank you for using PiNanas!"

    command -v netstat >/dev/null || return
    if netstat -lan | grep -qE ':53\W' ; then
        warn "Port 53/udp appears to be already in use. You should free it before starting PiNanas."
        cont "On Ubuntu 18.04+ systems, in order to free 53/udp you can disable your local DNS cache server:"
        cont "    sudo mkdir -p /etc/systemd/resolved.conf.d"
        cont "    echo -e '[Resolve]\nDNSStubListener=no' | sudo tee -a /etc/systemd/resolved.conf.d/disable-for-pinanas.conf"
        cont "    sudo systemctl force-reload systemd-resolved"
        cont "    sudo rm /etc/resolv.conf"
        cont "    sudo ln -s ../run/systemd/resolve/resolv.conf /etc/resolv.conf"
        cont "    sudo resolvectl dns $(route | grep ^default | awk '{print $8}') 8.8.8.8 8.8.4.4"
    fi
}

configure "$@" || exit $?
export_version
report
