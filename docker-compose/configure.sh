#!/bin/bash
ROOT="$(dirname "$(readlink -f "${0}")")"
DIST="$(readlink -f ${PWD})"

#
## Check context
#
if [[ ! -f "${DIST}/settings.yml" ]] ; then
    echo "$0: error: ${DIST}/settings.yml no such file." >&2
    echo "Copy ${ROOT}/settings.yml.sample to ${DIST}/settings.yml and fill in your personnal configuration." >&2
    exit 1
fi

if ! command -v ansible-playbook >/dev/null ; then
    echo "$0: error: command ansible-playbook not found." >&2
    echo "This script requires ansible. See <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html> for help installing it." >&2
    exit 1
fi

if [[ ${1} == "--force" ]] ; then
    OPT_FORCE=true
fi


#
## Apply private configuration
#

# Create playbook file
playbook=$(mktemp)
trap "rm -f -- ${playbook}" EXIT

# Install plugins
plugin_files="\
:${ROOT}/utils/ansible_passwords.py\
"
plugins_dir="$(dirname ${playbook})/filter_plugins"
mkdir -p "${plugins_dir}"
echo "${plugin_files}" | tr : '\n' | while read file ; do
  [[ -r "${file}" ]] && cp "${file}" "${plugins_dir}/$(basename ${file})"
done

# Playbook header
cat > ${playbook} <<EOH
---
- hosts: localhost
  gather_facts: yes
  tasks:
  - include_vars: ${DIST}/settings.yml
  - name: ensure application directories exist
    file:
      path: "${DIST}/{{ item[0] }}/{{ item[1] }}"
      state: directory
      mode: 0755
    loop: "{{ ['dhcpd', 'traefik', 'authelia', 'adguardhome'] | product(['config', 'data']) | list }}"
  - name: ensure traefik/acme.json exists
    file:
      path: "${DIST}/traefik/data/acme.json"
      state: touch
      mode: 0600
EOH

# Playbook tasks
for j2 in $(find "${ROOT}/templates" -type f -name "*.j2") ; do
    destdir="$(dirname "${DIST}/${j2#${ROOT}/templates/}")"
    filename="$(basename "${j2%.j2}")"
    cat >> ${playbook} <<EOT
  # handle ${j2}
  - name: ensure ${destdir} exists
    file:
      path: "${destdir}"
      state: directory
  - name: create ${destdir}/${filename} from settings
    template:
      src:  "${j2}"
      dest: "${destdir}/${filename}"
      force: $([[ ${OPT_FORCE} == true ]] && echo yes || echo no)
    delegate_to: localhost

EOT
done

EXTRA_VARS="{
  PUID: $(id -u),
  PGID: $(id -g)
}"

export ANSIBLE_LOCALHOST_WARNING=false
ansible-playbook \
    --inventory /dev/null \
    --extra-vars "${EXTRA_VARS}" \
    ${playbook}
