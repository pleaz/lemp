FROM debian:stretch-slim
MAINTAINER Anton Kuk "oprstfaq@gmail.com"

# Set frontend. We'll clean this later on!
ENV DEBIAN_FRONTEND noninteractive

# Locale
ENV LOCALE en_US.UTF-8

# PHP Timezone
ENV TZ=Europe/Moscow

# Set repositories
RUN apt-get -qq update && apt-get -qqy upgrade

# Install some basic tools needed for deployment
RUN apt-get -yqq install \
  apt-utils \
  debconf \
  dialog \
  locales \
  gnupg2 \
  curl \
  wget \
  lsb-release \
  ca-certificates \
  apt-transport-https \
  supervisor \
  openssl \
  aptitude \
  nano \
  htop \
  mc \
  software-properties-common \
  dirmngr \
  build-essential

# Install locale
RUN ln -s /etc/locale.alias /usr/share/locale/locale.alias
RUN \
  sed -i -e "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && \
  echo "LANG=en_US.UTF-8">/etc/default/locale && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8

# Install PHP7
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN aptitude update && aptitude install -y php7.1-fpm php7.1-mysql php7.1-curl php7.1-gd php7.1-intl php7.1-imap php7.1-json php7.1-mcrypt php7.1-pspell php7.1-recode php7.1-sqlite3 php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-mbstring php7.1-opcache php7.1-zip php7.1-bz2 php-memcache php-gettext php-pear php-imagick php-apcu
RUN mkdir -p /var/run/php

RUN sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/max_input_time = .*/max_input_time = 600/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/display_startup_errors = .*/display_startup_errors = On/" /etc/php/7.1/fpm/php.ini
COPY www.conf /etc/php/7.1/fpm/pool.d/

# PHP Timezone
RUN \
  echo $TZ | tee /etc/timezone && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  echo "date.timezone = \"$TZ\";" > /etc/php/7.1/fpm/conf.d/timezone.ini

# PHP IonCube
RUN \
  wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
  tar xvfz ioncube_loaders_lin_x86-64.tar.gz && \
  cp ioncube/ioncube_loader_lin_7.1.so /usr/lib/php/20151012/ && \
  echo "zend_extension = \"/usr/lib/php/20151012/ioncube_loader_lin_7.1.so\"" > /etc/php/7.1/fpm/conf.d/00-ioncube.ini && \
  rm ioncube_loaders_lin_x86-64.tar.gz && \
  rm -rf ioncube_loaders_lin_x86-64

# Install NGINX
RUN curl -O https://nginx.ru/keys/nginx_signing.key
RUN apt-key add nginx_signing.key
RUN echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list
RUN aptitude update && aptitude install -y nginx
COPY default.conf /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/

# NGINX logs
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

# Install MySql
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
RUN add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.mephi.ru/mariadb/repo/10.3/debian stretch main'
RUN { \
        echo "mariadb-server-10.3" mysql-server/root_password password '48115'; \
        echo "mariadb-server-10.3" mysql-server/root_password_again password '48115'; \
    } | debconf-set-selections \
    && aptitude update && aptitude install -y mariadb-server
COPY mariadb.cnf /etc/mysql/conf.d/

# Install Memcached
RUN aptitude install -y memcached

# Install PhpMyAdmin
#RUN mysqld -u mysql & aptitude install -y phpmyadmin
RUN aptitude install -y phpmyadmin
RUN dpkg-reconfigure phpmyadmin

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# Git
RUN aptitude install -y git
# useful command: git rm --cached docker -r

# Node
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN aptitude install -y nodejs
# useful command: npm cache verify

# Laravel
RUN composer global require "laravel/installer"
RUN export PATH="$PATH:$HOME/.composer/vendor/bin"
# TODO previous command not work, need to check it
# RUN laravel new

# ElasticSearch
# RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
# RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
# RUN aptitude update && aptitude install -y elasticsearch
# TODO don't working in docker container

# Redis
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" | tee -a /etc/apt/sources.list.d/backports.list
RUN aptitude update
RUN aptitude -t stretch-backports install redis-server
# TODO need to start service
# for test command: redis-cli

# import db
# > aptitude install python-pip
# > pip install redis
# > git clone https://github.com/RedisLabsModules/rejson.git
# > cd rejson && make
# add in redis cfg(/etc/redis/redis.conf) str - loadmodule ~/rejson/src/rejson.so
# > echo never > /sys/kernel/mm/transparent_hugepage/enabled
# and than restart redis-server
# > python init.py
# ...init.py
## import json
## import redis
## r = redis.StrictRedis()
## with open('theync_arr.json') as data_file:
##   arr = json.load(data_file)
##   for index, item in enumerate(arr):
##       r.execute_command('JSON.SET', index, '.', json.dumps(item))

# Clean packages
RUN aptitude -y upgrade
RUN aptitude clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Cfg supervisor
COPY supervisord.conf /etc/supervisor/conf.d/daemons.conf

# Working dir
WORKDIR /var/www/html

# Volume for www & mysql data
VOLUME ["/var/www/html"]
#VOLUME ["/var/lib/mysql"]

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/daemons.conf"]