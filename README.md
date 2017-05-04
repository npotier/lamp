# LAMP Scripts

This is a collection of old school bash script that i've created in order to provision a LAMP Server. Theses scripts are tested on Debian 8 (Jessie).

Warning : these scripts have been made for my personal use. I'm not a sysadmin so you should use them at your own risks.

## Usage

```bash
# Copy theses file on your new server
$ cd /path/to/lamp
$ ./lamp.sh
# MySQL ROOT password an deploy user password will be stored in LAMP_RESULT.txt
$ cat LAMP_RESULT.txt
$ ./varnish.sh
# The script will prompt the port you want Varnish to use. You can leave it empty, it will use the defaut 6081 port
# Make sure you have configured your DNS so that your domain name redirect to the server
$ ./vhost.sh
# Enter your domain name
$ ./mysql.sh
# Enter the MySQL root password and the name of the user/database you want to create
```


## lamp.sh script

Setup of a LAMP Stack :

* **Apache 2.4** with some _security_ features
* **PHP7** installed from _DotDeb_ Repositories
* **MySQLServer**
* **IPTables** with standard ports for a LAMP Stack (Ping, 22, 10022, 53, 80, 443, 25, 587, 110, 143, 123)
* **Fail2Ban** with standard setup for Apache
* **Git, Vim, curl**

## varnish.sh script

Install **Varnish 4** and specific settings (contained in varnish/default.vcl). This file is tested fot PHP / Symfony Web applications.

## mysql.sh script

Provision a user and a database

## vhost.sh

Create a vhost and the corresponding **Apache** configuration. This script use **getssl**, which allows to generate a SSL certificate thanks to Let's encrypt.

If **Varnish** is detected, the script will create an Apache reverse SSL proxy.



## TODO

* Improove security best practice configs
* Use PHP FPM ?
