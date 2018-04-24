#!/bin/sh

#set -e
set -x

DB_PORT=${DB_PORT:=5432}

: "${TTRSS_DB_HOST:="$DB_HOST"}"
: "${TTRSS_DB_USER:="$DB_USER"}"
: "${TTRSS_DB_PASS:="$DB_PASS"}"
: "${TTRSS_DB_NAME:="$DB_NAME"}"
: "${TTRSS_DB_PORT:="$DB_PORT"}"
: "${TTRSS_DB_TYPE:="$DB_TYPE"}"
: "${TTRSS_FEED_CRYPT_KEY:=""}"
: "${TTRSS_HOST_URL:="$HOST_URL"}"


# All these sed's are run as sudo because they're writing to /var/www/html/ttrss
sed -i -e "s/DB_TYPE_VALUE/$TTRSS_DB_TYPE/" /app/htdocs/config.php
sed -i -e "s/DB_HOST_VALUE/$TTRSS_DB_HOST/" /app/htdocs/config.php
sed -i -e "s/DB_USER_VALUE/$TTRSS_DB_USER/" /app/htdocs/config.php
sed -i -e "s/DB_NAME_VALUE/$TTRSS_DB_NAME/" /app/htdocs/config.php
sed -i -e "s/DB_PASS_VALUE/$TTRSS_DB_PASS/" /app/htdocs/config.php
sed -i -e "s/DB_PORT_VALUE/$TTRSS_DB_PORT/" /app/htdocs/config.php
sed -i -e "s/FEED_CRYPT_KEY_VALUE/$TTRSS_FEED_CRYPT_KEY/" /app/htdocs/config.php
sed -i -e "s#HOST_URL#$TTRSS_HOST_URL#" /app/htdocs/config.php

php /setup_db.php 
php-fpm --nodaemonize &
php /app/htdocs/update_daemon2.php &
lighttpd -D -f /etc/lighttpd/lighttpd.conf 

while true; do sleep 30; done;

#&& supervisord -c /etc/supervisor/supervisord.conf