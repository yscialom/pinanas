#!/bin/sh

. /configure-logging.sh

#
## Check
#

check () {
    if [ ! -f "/pinanas/dist/settings.yaml" ] ; then
        fatal "/pinanas/dist/settings.yaml no such file."
        cont "Copy ${PINANAS_SRC}/configure/settings.yaml.sample to ${PINANAS_DIST}/settings.yaml and fill in your personnal configuration."
        exit 1
    fi

    if [ "${1}" = "--force" ] ; then
        shift
        OPT_FORCE=true
        rm -rf -- /pinanas/venv
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
    export PIP_CACHE_DIR=/pinanas/venv/.pip-cache
    python3 -m pip install --upgrade pip
    pip3 install --requirement /pinanas/src/configure/settings-validator/requirements.txt
    pip3 install --requirement /pinanas/src/install/installer/requirements.txt

    ## Apply private configuration
    # Create playbook directory
    playbook_dir="/pinanas/venv/ansible"
    mkdir -p "${playbook_dir}"

    # Install plugins
    plugin_files="\
    :/pinanas/src/install/installer/ansible_passwords.py\
    "
    plugins_dir="${playbook_dir}/filter_plugins"
    mkdir -p "${plugins_dir}"

    echo "${plugin_files}" | tr : '\n' | while read -r file ; do
        if [ -r "${file}" ] ; then
            cp "${file}" "${plugins_dir}/$(basename "${file}")"
        fi
    done

    ## Playbooks
    playbook="${playbook_dir}/playbook.yaml"

    # Playbook header
    cat > ${playbook} <<EOH
---
- hosts: localhost
  gather_facts: yes
  gather_subset:
  - "!all"
  - all_ipv4_addresses
  tasks:
  - include_vars: /pinanas/src/configure/settings.yaml.defaults
  - include_vars: /pinanas/dist/settings.yaml
  - name: combine default + custom
    set_fact:
      pinanas: "{{ pinanas_defaults | combine(pinanas, recursive=True) }}"
  - name: ensure application directories exist
    file:
      path: "/pinanas/dist/{{ item[0] }}/{{ item[1] }}"
      state: directory
      mode: 0755
    loop: "{{ ['adguardhome', 'authelia', 'database', 'dhcpd', 'duplicati', 'heimdall', 'jellyfin', 'netdata', 'nextcloud', 'traefik'] | product(['config', 'data']) | list }}"
  - name: ensure log directories exist
    file:
      path: "/pinanas/dist/logs/{{ item }}"
      state: directory
      mode: 0750
    loop: ['authelia', 'fail2ban', 'nextcloud', 'traefik']
  - name: ensure media directories exist
    file:
      path: "/pinanas/dist/media/{{ item }}"
      state: directory
      mode: 0770
    loop: ['movies', 'tvshows']
  - name: ensure traefik/acme.json exists
    file:
      path: "/pinanas/dist/traefik/data/acme.json"
      state: touch
      mode: 0600
EOH

    # Playbook tasks
    find /pinanas/src/install/modules -type f -name "*.j2" | while read -r j2 ; do
        [[ "${j2}" =~ /docker-compose\..+\.yaml\.j2$ ]] && continue # skip module-specific docker-compose templates
        destdir="$(dirname "/pinanas/dist/${j2#/pinanas/src/install/modules/}")"
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

    # Specific playbooks
    find /pinanas/src/install/operations -type f -name "main.y*ml" | while read -r taskfile ; do
      echo "  - name: \"include task file '${taskfile}'\"" >> ${playbook}
      echo "    include_tasks: \"${taskfile}\"" >> ${playbook}
    done

    # Make Jinja find secrets.j2
    ln -fs /pinanas/src/install/installer/secrets.j2 ${playbook_dir}/.
}


#
## Validate
#

validate () {
    /pinanas/src/configure/settings-validator/validate.py \
        -s /pinanas/src/configure/settings-validator/schema.json \
        -y /pinanas/dist/settings.yaml
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
        "${playbook}" \
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
docker rmi pinanas-config
docker images -f dangling=true -q | xargs docker rmi
rm -- \$0
EOF
    chmod +x "/pinanas/dist/distclean.sh"
}


#
## Uninstall
#

uninstall () {
    cat > "/pinanas/dist/uninstall.sh" <<EOF
#!/bin/bash
[[ -x ./distclean.sh ]] && ./distclean.sh
trap "rm .images" EXIT
docker-compose images -q >.images
docker-compose down
xargs docker image rm <.images
rm -rf -- docker-compose.yaml */config
rm -- \$0
echo "settings.yaml and */data/ are left untouched and should be removed manually."
EOF
    chmod +x "/pinanas/dist/uninstall.sh"
}


#
## === ENTRY POINT ===
#

check "$@"
prepare
validate || exit $?
install "$@" || exit $?
clean
uninstall
