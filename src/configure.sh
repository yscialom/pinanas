#!/bin/bash
ROOT="$(dirname "$(readlink -f "${0}")")"
DIST="$(readlink -f ${PWD})"
VENV="${DIST}/.venv"


#
## log
#

function color()  { echo -e "\033[${1}m${2}\033[0m" ; }
function red()    { color "0;31" "$*" ; }
function yellow() { color "0;33" "$*" ; }
function green()  { color "0;32" "$*" ; }

function log ()  { echo "$(basename "$0") [$1] $2" >&2 ; }
function info()  { log " $(green INFO)"  "$*" ; }
function cont()  { log "     "           "$*" ; }
function warn()  { log " $(yellow WARN)" "$*" ; }
function error() { log "$(red ERROR)"    "$*" ; }
function fatal() { log "$(red FATAL)"    "$(red $*)" ; }


#
## Check context
#

if [[ ! -f "${DIST}/settings.yml" ]] ; then
    fatal "${DIST}/settings.yml no such file."
    cont "Copy ${ROOT}/settings.yml.sample to ${DIST}/settings.yml and fill in your personnal configuration."
    exit 1
fi

if ! command -v pip >/dev/null ; then
    fatal "command pip not found."
    cont "This script requires pip. See <https://pypi.org/project/pip/> for help installing it."
    exit 1
fi

if [[ ${1} == "--force" ]] ; then
    OPT_FORCE=true
    rm -rf -- "${VENV}"
fi


#
## Install tools
#

if ! python3 -m venv "${VENV}" ; then
    error "'python -m venv' failed with code $?."
    cont "This script requires python virtual environments. See <https://docs.python.org/3/library/venv.html> for help installing it."
    exit 1
fi

source "${VENV}"/bin/activate

python3 -m pip install --upgrade pip
pip install ansible==4.2


#
## Apply private configuration
#

# Create playbook file
playbook="${VENV}"/ansible/playbook.yml
mkdir -p $(dirname "${playbook}")

# Install plugins
plugin_files="\
:${ROOT}/utils/ansible_passwords.py\
"
plugins_dir="$(dirname ${playbook})/filter_plugins"
mkdir -p "${plugins_dir}"

echo "${plugin_files}" | tr : '\n' | while read file ; do
    if [[ -r "${file}" ]] ; then
        pip install -r "$(dirname "${file}")"/requirements.txt
        cp "${file}" "${plugins_dir}/$(basename ${file})"
    fi
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


#
## Install
#

EXTRA_VARS="{
  PUID: $(id -u),
  PGID: $(id -g)
}"

export ANSIBLE_LOCALHOST_WARNING=false
ansible-playbook \
    --inventory /dev/null \
    --extra-vars "${EXTRA_VARS}" \
    ${playbook}

ansible_status=$?
if [[ ${ansible_status} != 0 ]] ; then
    error "ansible returned error code ${ansible_status}."
    exit ${ansible_status}
fi

info "Configuration successful."
cont "You can clean work files with ./distclean.sh"
cont "Start your services with docker-compose up -d"

if [[ -n $(ss -Hul "sport = :domain") ]] ; then
    warn "Port udp/53 appears to be already in use. You should free it before starting pinanas."
    cont "On Ubuntu 18.04+ systems, in order to free udp/53 you can disable your local DNS cache server:"
    cont "    sudo mkdir -p /etc/systemd/resolved.conf.d"
    cont "    echo -e '[Resolve]\nDNSStubListener=no' | sudo tee -a /etc/systemd/resolved.conf.d/disable-for-pinanas.conf"
    cont "    sudo systemctl force-reload systemd-resolved"
    cont "    sudo rm /etc/resolv.conf"
    cont "    sudo ln -s ../run/systemd/resolve/resolv.conf /etc/resolv.conf"
fi


#
## Clean
#

cat > "${DIST}/distclean.sh" <<EOF
#!/bin/bash
rm -rf -- "${VENV}"
rm -- \$0
EOF
chmod +x "${DIST}/distclean.sh"
