#!/bin/bash

#
## === Actions ===
#

# disable Raspbian setup wizard
rm -f -- /etc/xdg/autostart/piwiz.desktop
kill -9 $(ps aux | grep '[p]iwiz' | awk '{print $2}')

# force pi user to change password upon first login
chage -d 0 pi

# ensure ssh is running
systemctl enable ssh

# enable lightdm autologin
sed -i \
    -e 's/#autologin-guest=false/autologin-guest=false/' \
    -e 's/#autologin-user=user/autologin-user=pi/' \
    -e 's/#autologin-user-timeout=0/autologin-user-timeout=0/' \
    /etc/lightdm/lightdm.conf
