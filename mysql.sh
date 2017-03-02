#!/bin/bash

source utils.sh

READ "What is the database name" "MYSQL_DATABASE_NAME"
READ "What is the MySQL root password" "MYSQL_ROOT_PASSWORD"

MYSQL_USER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 15 ; echo)
RUN "echo 'MYSQL_USER_PASSWORD=$MYSQL_USER_PASSWORD' >> MYSQL_${MYSQL_DATABASE_NAME}_RESULT.txt"

INFO "Creating database $MYSQL_DATABASE_NAME"
RUN "mysql -uroot -p'${MYSQL_ROOT_PASSWORD}' -e 'CREATE DATABASE ${MYSQL_DATABASE_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;'"
RUN "mysql -uroot -p'${MYSQL_ROOT_PASSWORD}' -e \"CREATE USER ${MYSQL_DATABASE_NAME}@localhost IDENTIFIED BY '${MYSQL_USER_PASSWORD}';\""
RUN "mysql -uroot -p'${MYSQL_ROOT_PASSWORD}' -e 'GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE_NAME}.* TO '${MYSQL_DATABASE_NAME}'@'localhost';'"
RUN "mysql -uroot -p'${MYSQL_ROOT_PASSWORD}' -e 'FLUSH PRIVILEGES;'"
