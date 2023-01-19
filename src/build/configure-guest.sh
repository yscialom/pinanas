#!/bin/sh

. /configure-logging.sh
. /configure-uninstaller.sh

#
## Check
#

check () {
    if [ ! -f "/pinanas/dist/settings.yaml" ] ; then
        fatal "/pinanas/dist/settings.yaml no such file."
        cont "Copy ${PINANAS_SRC}/settings.yaml.sample to ${PINANAS_DIST}/settings.yaml and fill in your personnal configuration."
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
    python3 -m pip install --upgrade pip
    pip3 install ansible==5.6

    ## Apply private configuration
    # Create playbook directory
    playbook_dir="/pinanas/venv/ansible"
    mkdir -p "${playbook_dir}"

    # Install plugins
    plugin_files="\
    :/pinanas/src/utils/ansible_passwords.py\
    "
    plugins_dir="${playbook_dir}/filter_plugins"
    mkdir -p "${plugins_dir}"

    echo "${plugin_files}" | tr : '\n' | while read -r file ; do
        if [ -r "${file}" ] ; then
            pip3 install -r "$(dirname "${file}")"/requirements.txt
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
  tasks:
  - include_vars: /pinanas/src/default-settings.yaml
  - include_vars: /pinanas/dist/settings.yaml
  - name: combine default + custom
    set_fact:
      pinanas: "{{ pinanas_default | combine(pinanas, recursive=True) }}"
  - name: ensure application directories exist
    file:
      path: "/pinanas/dist/{{ item[0] }}/{{ item[1] }}"
      state: directory
      mode: 0755
    loop: "{{ ['adguardhome', 'authelia', 'database', 'dhcpd', 'duplicati', 'heimdall', 'jellyfin', 'netdata', 'nextcloud', 'traefik'] | product(['config', 'data']) | list }}"
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

    # Specific playbooks
    find /pinanas/src/tasks -type f -name "main.y*ml" | while read -r taskfile ; do
      echo "  - name: \"include task file '${taskfile}'\"" >> ${playbook}
      echo "    include_tasks: \"${taskfile}\"" >> ${playbook}
    done

    # Make Jinja find secrets.j2
    ln -fs /pinanas/src/utils/secrets.j2 ${playbook_dir}/.
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
## === ENTRY POINT ===
#

check "$@"
prepare
install "$@"
clean
uninstaller
