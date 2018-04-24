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
sed -i -e "s/DB_TYPE_VALUE/$TTRSS_DB_TYPE/" /var/www/html/ttrss/config.php
sed -i -e "s/DB_HOST_VALUE/$TTRSS_DB_HOST/" /var/www/html/ttrss/config.php
sed -i -e "s/DB_USER_VALUE/$TTRSS_DB_USER/" /var/www/html/ttrss/config.php
sed -i -e "s/DB_NAME_VALUE/$TTRSS_DB_NAME/" /var/www/html/ttrss/config.php
sed -i -e "s/DB_PASS_VALUE/$TTRSS_DB_PASS/" /var/www/html/ttrss/config.php
sed -i -e "s/DB_PORT_VALUE/$TTRSS_DB_PORT/" /var/www/html/ttrss/config.php
sed -i -e "s/FEED_CRYPT_KEY_VALUE/$TTRSS_FEED_CRYPT_KEY/" /var/www/html/ttrss/config.php
sed -i -e "s#HOST_URL#$TTRSS_HOST_URL#" /var/www/html/ttrss/config.php

php /var/www/html/ttrss/setup_db.php 

supervisord -c /etc/supervisor/supervisord.conf