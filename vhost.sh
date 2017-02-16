#!/bin/bash

source utils.sh


READ "What is the URL of the host you want to create ?" "APACHE_DOMAIN"

INFO "Creating the host folder"
RUN "mkdir -p /var/www/$APACHE_DOMAIN"
RUN "mkdir -p /var/www/$APACHE_DOMAIN/ssl"

INFO "Copying template vhost.conf into /etc/apache2/sites-available/$APACHE_DOMAIN.conf"
RUN "cp apache/vhost.conf /etc/apache2/sites-available/$APACHE_DOMAIN.conf"

INFO "Editing Apache template"
RUN "sed -i 's/__DOMAIN__/$APACHE_DOMAIN/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"

command -v getssl >/dev/null 2>&1 || {
    INFO "getssl is required but is not insalled. Installing"
    RUN "apt-get -qq update"
    RUN "apt-get -y -qq install host"
    RUN "curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > /usr/local/bin/getssl ; chmod 777 /usr/local/bin/getssl"
}

INFO "Copying template getssl.cfg into /var/www/$APACHE_DOMAIN/getssl.cfg"
RUN "cp apache/getssl.cfg /var/www/$APACHE_DOMAIN/getssl.cfg"

INFO "Editing GetSSL template"
RUN "sed -i 's/__DOMAIN__/$APACHE_DOMAIN/g' /var/www/$APACHE_DOMAIN/getssl.cfg"

INFO "Running GetSSL"
RUN "getssl -a -w /var/www/"
