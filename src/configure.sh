#!/bin/sh
[ -z "${PINANAS_SRC}" ]  && PINANAS_SRC="$(dirname "$(readlink -f "${0}")")"
[ -z "${PINANAS_DIST}" ] && PINANAS_DIST="$(readlink -f "${PWD}")"
[ -z "${PINANAS_VENV}" ] && PINANAS_VENV="${PINANAS_DIST}/.venv"


#
## Logging
#

color()  { printf "\033[%sm${2}\033[0m\n" "${1}"; }
red()    { color "0;31" "$*" ; }
yellow() { color "0;33" "$*" ; }
green()  { color "0;32" "$*" ; }

log ()  { echo "$(basename "$0") [$1] $2" >&2 ; }
info()  { log " $(green INFO)"  "$*" ; }
cont()  { log "     "           "$*" ; }
warn()  { log " $(yellow WARN)" "$*" ; }
error() { log "$(red ERROR)"    "$*" ; }
fatal() { log "$(red FATAL)"    "$(red "$@")" ; }


#
## Run in Docker
#
run_in_docker () {
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        -v "${PINANAS_SRC}":/pinanas/src:ro \
        -v "${PINANAS_DIST}":/pinanas/dist \
        -v "${PINANAS_VENV}":/pinanas/venv \
        -e PINANAS_SRC="${PINANAS_SRC}" \
        -e PINANAS_DIST="${PINANAS_DIST}" \
        -e PINANAS_VENV="${PINANAS_VENV}" \
        python:3-alpine \
        sh -c "apk add --no-cache gcc musl-dev libffi-dev && \"/pinanas/src/$(basename "${0}")\" $@"
}


#
## Check
#

check () {
    if [ ! -f "/pinanas/dist/settings.yml" ] ; then
        fatal "/pinanas/dist/settings.yml no such file."
        cont "Copy ${PINANAS_SRC}/settings.yml.sample to ${PINANAS_DIST}/settings.yml and fill in your personnal configuration."
        exit 1
    fi

    if [ "${1}" = "--force" ] ; then
        shift
        OPT_FORCE=true
        rm -rf -- /pianans/venv
    fi
}


#
## Prepare
#

prepare () {
    ## Install tools
    if ! python3 -m venv /pinanas/venv ; then
        error "'python3 -m venv' failed with code $?."
        exit 2
    fi

    . /pinanas/venv/bin/activate
    python3 -m pip install --upgrade pip
    pip3 install ansible==4.2


    ## Apply private configuration

    # Create playbook file
    playbook=/pinanas/venv/ansible/playbook.yml
    mkdir -p "$(dirname "${playbook}")"

    # Install plugins
    plugin_files="\
    :/pinanas/src/utils/ansible_passwords.py\
    "
    plugins_dir="$(dirname ${playbook})/filter_plugins"
    mkdir -p "${plugins_dir}"

    echo "${plugin_files}" | tr : '\n' | while read -r file ; do
        if [ -r "${file}" ] ; then
            pip3 install -r "$(dirname "${file}")"/requirements.txt
            cp "${file}" "${plugins_dir}/$(basename "${file}")"
        fi
    done

    ## Playbooks
    # Playbook header
    cat > ${playbook} <<EOH
---
- hosts: localhost
  gather_facts: yes
  tasks:
  - include_vars: /pinanas/dist/settings.yml
  - name: ensure application directories exist
    file:
      path: "/pinanas/dist/{{ item[0] }}/{{ item[1] }}"
      state: directory
      mode: 0755
    loop: "{{ ['dhcpd', 'traefik', 'authelia', 'adguardhome', 'heimdall', 'nextcloud'] | product(['config', 'data']) | list }}"
  - name: ensure traefik/acme.json exists
    file:
      path: "/pinanas/dist/traefik/data/acme.json"
      state: touch
      mode: 0600
EOH

    # Playbook tasks
    find /pinanas/src/templates -type f -name "*.j2" | while read -r j2 ; do
        destdir="$(dirname "/pinanas/dist/${j2#/pinanas/src/templates/}")"
        filename="$(basename "${j2%.j2}")"
        cat >> ${playbook} <<EOT
- name: ensure ${destdir} exists
  file:
    path: "${destdir}"
    state: directory
- name: create ${destdir}/${filename} from settings
  template:
    src:  "${j2}"
    dest: "${destdir}/${filename}"
    force: $([ "${OPT_FORCE}" = "true" ] && echo yes || echo no)
  delegate_to: localhost

EOT
    done
}


#
## Install
#

install () {
    EXTRA_VARS="{
      PUID: $(id -u),
      PGID: $(id -g)
    }"

    export ANSIBLE_LOCALHOST_WARNING=false
    ansible-playbook \
        --inventory /dev/null \
        --extra-vars "${EXTRA_VARS}" \
        ${playbook} \
        "$@"

    ansible_status=$?
    if [ ${ansible_status} -ne 0 ] ; then
        error "ansible returned error code ${ansible_status}."
        exit ${ansible_status}
    fi
}


#
## Report
#

report () {
    info "Configuration successful."
    cont "You can clean work files with ./distclean.sh"
    cont "Start your services with docker-compose up -d"

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

#
## Clean
#

clean () {
    cat > "${PINANAS_DIST}/distclean.sh" <<EOF
    #!/bin/bash
    rm -rf -- "${PINANAS_VENV}"
    rm -- \$0
EOF
    chmod +x "/pinanas/dist/distclean.sh"
}


#
## === ENTRY POINT ===
#

main_host () {
    run_in_docker "$@"
    report
}

main_guest () {
    check "$@"
    prepare
    install "$@"
    clean
}

if [ -f /.dockerenv ]
then main_guest "$@"
else main_host "$@"
fi
