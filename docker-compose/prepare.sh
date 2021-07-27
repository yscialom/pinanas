#!/bin/bash

ROOT="$(dirname "$(readlink -f "${0}")")"

#
## Check context
#
if [[ ! -f "${ROOT}/settings.yml" ]] ; then
    echo "$0: error: ${ROOT}/settings.yml no such file." >&2
    echo "Copy ${ROOT}/settings.yml.sample to ${ROOT}/settings.yml and fill in your personnal configuration." >&2
    exit 1
fi

if ! command -v ansible-playbook >/dev/null ; then
    echo "$0: error: command ansible-playbook not found." >&2
    echo "This script requires ansible. See <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html> for help installing it." >&2
    exit 1
fi
    


#
## Apply private configuration
#

# Create playbook file
playbook=$(mktemp)
trap "rm -f -- ${playbook}" EXIT

# Playbook header
cat > ${playbook} <<EOH
---
- hosts: localhost
  gather_facts: yes
  tasks:
  - include_vars: ${ROOT}/settings.yml
EOH

# Playbook tasks
for j2 in $(find "${ROOT}/templates" -type f -name "*.j2") ; do
    destdir="$(dirname "${ROOT}/${j2#${ROOT}/templates/}")"
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
    delegate_to: localhost

EOT
done

ANSIBLE_LOCALHOST_WARNING=false ansible-playbook -i /dev/null ${playbook}
