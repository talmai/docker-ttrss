FROM php:7-fpm-alpine
MAINTAINER Talmai Oliveira <to@talm.ai>

RUN set -ex \
  && apk --no-cache add \
    postgresql-dev mysql-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql

RUN apk update \
	&& apk add nginx supervisor php7-fpm php7-cli php7-curl php7-gd php7-json \
  		php7-pgsql php5-mysql git php7-pdo php7-dev php7-common

# add ttrss as the only nginx site
RUN mkdir -p /etc/nginx/sites-enabled/ttrss /etc/nginx/sites-enabled/ttrss
ADD ttrss.nginx.conf /etc/nginx/sites-available/ttrss
RUN ln -s /etc/nginx/sites-available/ttrss /etc/nginx/sites-enabled/ttrss

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# Copy files to docker
COPY entrypoint.php /var/www/html/ttrss/entrypoint.php
COPY supervisord.conf /etc/supervisor/supervisord.conf

#RUN ls -lAF /usr/lib/php5/modules
RUN find / -name php.ini
RUN find / -name pdo_mysql.*
RUN php -i|grep PDO
RUN find / -name php-fpm

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

# always check parameters with current ENV when RUNning container, then monitor all services
CMD php /var/www/html/ttrss/entrypoint.php && supervisord -c /etc/supervisor/supervisord.conf