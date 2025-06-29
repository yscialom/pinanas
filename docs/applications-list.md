Applications: List and Descriptions
===================================

Mandatory applications
----------------------
### DHCPD
DHCP Daemon: answerq to dhcp requests to assign IPs to clients and set their primary DNS server. This is necessary for
AdGuard Home to work with zero configuration on clients.

### TRAEFIK
Reverse proxy (HTTP, TCP, UDP): route requests to services hosted or not on the same host. This is useful to add SSO
(authelia), HTTPS (let's encrypt), and protect services not suited to face the outside.

### FAIL2BAN
Fail2ban ban hosts that cause multiple authentication errors.

### AUTHELIA
Single Sign On: handle authentification to users on the whole network.


Optionnal applications
----------------------
### AD GUARD HOME
AdGuard Home is a network-wide software for blocking ads and tracking. After you set it up, it'll cover ALL your home
devices, and you don't need any client-side software for that.

### DUPLICATI
Duplicati is an open source backup application, which encrypts data prior to uploading it. The user interface is
web-based and allows you to control all the options offered by Duplicati, from a simple and intuitive interface.

### HEIMDALL
Heimdall Application Dashboard is a dashboard for all your web applications.

### JELLYFIN
Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media. It is an
alternative to the proprietary Emby and Plex, to provide media from a dedicated server to end-user devices via
multiple apps.

### NETDATA
Netdata is a tool designed to collect real-time metrics, such as CPU usage, disk activity, bandwidth usage, website
visits, _etc_.

### NEXTCLOUD
Nextcloud gives you access to all your files wherever you are. This configuration uses MariaDB as database.
