# LAMP Scripts
simple LAMP scripts used for setting up servers

Warning : these scripts have been made for my personal use. I'm not a sysadmin so you should use them at your own risks.

## lamp.sh

This script installs :

* Git
* Vim
* Apache2 and securing it (to be improved)
* MySQL Server
* iptables and configure it with these basic rules : https://gist.github.com/npotier/0c037e42ae655a8564c2
* fail2ban and enable it for apache

This script also create a user "deploy" to the group www-data.

Generated password (MySQL and deploy user) are stored in the output file "LAMP_RESULT.txt"


## vhost.sh

This script configure a new vhost to Apache

Features :

* HTTP and HTTPS
* HTTPS is managed with getssl (https://github.com/srvrco/getssl)


## utils.sh

This script contains useful functions used by other scripts.
