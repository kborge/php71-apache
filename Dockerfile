FROM php:7.1-apache

ADD add_php.ini /usr/local/etc/php/conf.d/

RUN apt-get update -y && apt-get install -y libpng-dev libjpeg-dev zip unzip git yarn gnupg
RUN docker-php-ext-configure gd \
  --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ \
  && \
  docker-php-ext-install pdo pdo_mysql gd mbstring zip
RUN apt-get install -y autoconf pkg-config libssl-dev && \
  pecl install mongodb && docker-php-ext-enable mongodb

### Node
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
  4ED778F539E3634C779C87C6D7062848A1AB005C \
  94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
  B9AE9905FFD7803F25714661B63B535A4C206CA9 \
  77984A986EBC2AA786BC0F66B01FBB92821C587A \
  71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
  FD3A5288F042B6850C66B31F09FE44734EB7990E \
  8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
  ; do \
  gpg --no-tty --keyserver pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 10.14.2

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --no-tty --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

### composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Modify write permission for apache
RUN usermod -u 1000 www-data \
  && groupmod -g 1000 www-data

RUN a2enmod rewrite

### QuickFix
# RUN chmod -R 777 storage