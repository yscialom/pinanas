#!/bin/bash

#
## === Actions ===
#

# force pi user to change password upon first login
chage -d 0 pi

# ensure ssh is running
systemctl enable ssh
