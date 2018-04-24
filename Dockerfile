FROM php:7-fpm-alpine
MAINTAINER Talmai Oliveira <to@talm.ai>

RUN set -ex \
  && apk --no-cache add \
    postgresql-dev mysql-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql

RUN apk update \
	&& apk add nginx supervisor php7-fpm php7-cli php7-curl php7-gd php7-json \
  		php7-pgsql php5-mysql git php7-pdo php7-dev php7-common

# install ttrss and patch configuration
WORKDIR /var/www
RUN git clone https://tt-rss.org/gitlab/fox/tt-rss.git /var/www/html/ttrss \
    &&  git clone https://github.com/reuteras/ttrss_plugin-af_feedmod.git /var/www/html/ttrss/plugins.local/af_feedmod \
    && git clone https://github.com/fastcat/tt-rss-ff-xmllint /tmp/ff_xmllint \
    && mv /tmp/ff_xmllint/ff_xmllint /var/www/html/ttrss/plugins.local \
# Clean up
    && rm -rf /var/www/html/ttrss/.git \
    && rm -rf /var/www/html/ttrss/plugins.local/af_feedmod/.git \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* 

# add ttrss as the only nginx site
RUN mkdir -p /etc/nginx/sites-enabled/ttrss /etc/nginx/sites-enabled/ttrss
ADD ttrss.nginx.conf /etc/nginx/sites-available/ttrss
RUN ln -s /etc/nginx/sites-available/ttrss /etc/nginx/sites-enabled/ttrss
RUN mkdir -p /run/nginx/
RUN chmod -R 777 /var/www/html/ttrss/cache
RUN chmod -R 777 /var/www/html/ttrss/feed-icons

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# Copy files to docker
ADD setup_db.php /var/www/html/ttrss/setup_db.php
ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD config.php /var/www/html/ttrss/config.php
ADD startup.sh /var/www/html/ttrss/startup.sh
RUN chmod 777 /var/www/html/ttrss/startup.sh

RUN apk add --no-cache bash gawk sed grep bc coreutils

# always check parameters with current ENV when RUNning container, then monitor all services
ENTRYPOINT ["/var/www/html/ttrss/startup.sh"]
CMD echo "running..."