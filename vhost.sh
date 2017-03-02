#!/bin/bash

source utils.sh


READ "What is the URL of the host you want to create ?" "APACHE_DOMAIN"
INFO "Ok, let's create a vhost for $APACHE_DOMAIN"

TEMPLATE="vhost_varnish_ssl.conf"
INFO "Checking if varnish is installed."
command -v varnishd >/dev/null 2>&1 || {
    INFO "Varnish is not installed. Installing VHOST the classic way"
    TEMPLATE="vhost.conf"
}


if [ $TEMPLATE = "vhost_varnish_ssl.conf" ]
then
    INFO "Varnish is installed. Let's configure the port it's listening."
    READ "Varnish is installed. Can you tell me which port Varnish is listening to (default 6081) ?" "VARNISH_PORT"
    if [ "$VARNISH_PORT" = "" ]
    then
        VARNISH_PORT="6081"
    fi
fi

INFO "Creating the host folder"
RUN "mkdir -p /var/www/$APACHE_DOMAIN/current/web"
RUN "mkdir -p /var/www/$APACHE_DOMAIN/ssl"

INFO "Copying template $TEMPLATE into /etc/apache2/sites-available/$APACHE_DOMAIN.conf"
RUN "cp apache/$TEMPLATE /etc/apache2/sites-available/$APACHE_DOMAIN.conf"

INFO "Editing Apache template"
RUN "sed -i 's/__DOMAIN__/$APACHE_DOMAIN/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"

INFO "Enabling Apache mods : rewrite headers expires"
RUN "a2enmod ssl rewrite headers expires"

if [ $TEMPLATE = "vhost_varnish_ssl.conf" ]
then
    INFO "Enabling Apache mods : proxy proxy_http proxy_ajp rewrite deflate headers proxy_balancer proxy_connect xml2enc proxy_html"
    RUN "a2enmod proxy proxy_http proxy_ajp rewrite deflate headers proxy_balancer proxy_connect xml2enc proxy_html"
fi

INFO "Enabling vhost"
RUN "a2ensite $APACHE_DOMAIN.conf"
RUN "service apache2 reload"

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
RUN "getssl -a -w /var/www"

INFO "Activating VHOST SSL"
RUN "sed -i 's/#SSLEngine/SSLEngine/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"
RUN "sed -i 's/#SSLCertificateFile/SSLCertificateFile/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"
RUN "sed -i 's/#SSLCertificateChainFile/SSLCertificateChainFile/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"
RUN "sed -i 's/#SSLCertificateKeyFile/SSLCertificateKeyFile/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"

if [ $TEMPLATE = "vhost_varnish_ssl.conf" ]
then
    RUN "sed -i 's/__VARNISH_PORT__/$VARNISH_PORT/g' /etc/apache2/sites-available/$APACHE_DOMAIN.conf"
fi

INFO "Ok ! Let's set rights to deploy User dans reload Apache."


RUN "rm -Rf /var/www/$APACHE_DOMAIN/current"
RUN "chown -R deploy:www-data /var/www/$APACHE_DOMAIN"
RUN "service apache2 reload"

INFO "All done !"
