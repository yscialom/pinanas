#!/bin/bash
cd $(dirname $0)

# Setup local machine to connect to hosts
host_file=hosts/all.yml

if [[ ! -f ${host_file} ]] ; then
    echo "===[ Setup ssh connection to pinanas host ]==="
    read -p "pinanas hostname or ip: " pinanas_host

    echo "  - create ansible host file $(readlink -f ${host_file})"
    sed "s/@PINANAS_HOST@/${pinanas_host}/" <${host_file}.in >${host_file}

    echo "  - allow ${USER}@${HOSTNAME} to connect to pi@${pinanas_host} with an ssh key"
    ssh-copy-id pi@${pinanas_host}
fi

# Install ansible roles from Galaxy
echo
echo "===[ Get dependencies playbooks ]==="
ansible-galaxy collection install community.mysql
for collection in geerlingguy.nginx geerlingguy.php geerlingguy.mysql nierdz.nextcloud ; do
    ansible-galaxy install ${collection}
done

# Play ansible roles
echo
echo "===[ Install PiNanas ]==="
ansible-playbook playbook.yml -i hosts/all.yml
