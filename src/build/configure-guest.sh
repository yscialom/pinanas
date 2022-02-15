#!/bin/sh

. /configure-logging.sh

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

    mkdir /pinanas-config/keys

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
## Clean
#

clean () {
    cat > "/pinanas/dist/distclean.sh" <<EOF
#!/bin/bash
rm -rf -- "${PINANAS_VENV}"
rm -- \$0
EOF
    chmod +x "/pinanas/dist/distclean.sh"
}


#
## === ENTRY POINT ===
#

check "$@"
prepare
install "$@"
clean
