#!/bin/bash

source utils.sh


INFO "Checking if varnish is installed."
command -v varnishd >/dev/null 2>&1 || {
    INFO "Varnish is not installed. Installing"
    RUN "apt-get -qq update"
    RUN "apt-get -y -qq install varnish"
}

INFO "Varnish is installed. Let's configure the port it's listening."
READ "What port do you want Varnish to listen (default 6081)?" "VARNISH_PORT"

if [ "$VARNISH_PORT" = "" ]
then
    VARNISH_PORT="6081"
fi

INFO "Allright ! Let's configure Varnish to listen to port $VARNISH_PORT"

RUN "sed -i 's/DAEMON_OPTS=\"-a :6081/DAEMON_OPTS=\"-a :$VARNISH_PORT/g' /etc/default/varnish"
RUN "sed -i 's/6081/$VARNISH_PORT/g' /etc/default/varnish"

INFO "Copying template default.vcl into /etc/varnish/default.vcl"
RUN "cp varnish/default.vcl /etc/varnish/default.vcl"

RUN "service varnish restart"

INFO "All done !"
