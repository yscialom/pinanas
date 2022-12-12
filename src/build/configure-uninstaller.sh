#!/bin/sh

. /configure-logging.sh

#
## Uninstaller-script
#

uninstaller () {
    cat > "/pinanas/dist/uninstall.sh" << \EOF
#!/bin/bash
docker stop $(docker ps -a -q)
docker rm -v $(docker ps -a -q)
docker volume prune -f
docker image prune -f
docker rmi $(docker images -a -q) -f
if [ -d ".venv/" ]
then
    echo ".venv/ directory will be removed."
    rm -r .venv/
fi
rm -r $(ls -I "settings.yaml*")
EOF
    chmod +x "/pinanas/dist/uninstall.sh"
}


#
## === ENTRY POINT ===
#

uninstaller
