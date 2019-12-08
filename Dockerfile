FROM php:7.3.0-apache
RUN apt-get update && apt-get install --fix-missing wget -y
RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y gnupg
RUN cd /tmp
RUN wget https://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg

RUN apt-get update && apt-get install --fix-missing -y \
  libgd3 \
  libgd-dev\
  apt-transport-https \
  apt-utils \
  cloc \
  imagemagick \
  graphviz \
  git \
  libicu-dev \
  libpng-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  linux-libc-dev \
  mysql-client \
  nano \
  ruby-dev \
  rubygems \
  sudo \
  tree \
  vim \
  memcached \
  libmemcached-tools \
  libmemcached-dev \
  wget \
  bash-completion \
  zip

RUN chmod +x /usr/local/bin/docker-php-ext-install
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install calendar
RUN docker-php-ext-install exif
RUN docker-php-ext-install intl
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install soap
RUN docker-php-ext-install xsl
#RUN docker-php-ext-install zip
#
## SASS and Compass installation
RUN gem install sass
RUN gem install compass

# Installation node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install -y nodejs

# Installation of LESS
RUN npm install -g less && npm install -g less-plugin-clean-css

# Installation of Grunt
RUN npm install -g grunt-cli

# Installation of Gulp
RUN npm install -g gulp
# Installation fo Bower
RUN npm install -g bower

# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Install xdebug. We need at least 2.4 version to have PHP 7 support.
RUN cd /tmp/ && wget http://xdebug.org/files/xdebug-2.8.0.tgz && tar -xvzf xdebug-2.8.0.tgz && cd xdebug-2.8.0/ && phpize && ./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config && make && make install
RUN cd /tmp/xdebug-2.8.0 && cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/
RUN echo 'zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20180731/xdebug.so' >> /usr/local/etc/php/php.ini
RUN touch /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo xdebug.remote_enable=1 >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo xdebug.remote_autostart=0 >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo xdebug.remote_connect_back=1 >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo xdebug.remote_port=9000 >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo xdebug.remote_log=/tmp/php7-xdebug.log >> /usr/local/etc/php/conf.d/xdebug.ini

RUN rm -rf /var/www/html
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html
RUN chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www

COPY config/apache2.conf /etc/apache2

# Installation of Opcode cache
RUN ( \
  echo "opcache.memory_consumption=128"; \
  echo "opcache.interned_strings_buffer=8"; \
  echo "opcache.max_accelerated_files=4000"; \
  echo "opcache.revalidate_freq=2"; \
  echo "opcache.fast_shutdown=1"; \
  echo "opcache.enable_cli=1"; \
  ) > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires && service apache2 restart
RUN apt-get install libfreetype6-dev
# ssh keys
RUN mkdir /var/www/.ssh/
RUN chown -R www-data:www-data /var/www/.ssh/
RUN chmod 600 /var/www/.ssh/
RUN useradd web -d /var/www -g www-data -s /bin/bash
RUN usermod -aG sudo web
RUN echo 'web ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -R web:www-data /var/www/html
RUN chown -R web:www-data /var/www/html
# ADD BASHRC CONFIG
COPY config/.bashrc /root/.bashrc
# Expose 80 for apache, 9000 for xdebug
EXPOSE 80 9000
