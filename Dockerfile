FROM centos:7
MAINTAINER Joe Nichols

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_CTYPE UTF-8
ENV BUNDLE_PATH /var/lib/jenkins/bundle

WORKDIR /tmp

## The CentOS 7 official software repositories have PHP 5.4 which has reached the end of life and no longer actively maintained by the developers.
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
 yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum update -y && yum install -y centos-release-scl epel-release
RUN yum install -y \
 yum-utils \
 curl \
 wget \
 unzip \
 gnupg \
 git \
 rrdtool \
 nodejs \
 npm && \
 node -v \
 npm -v

RUN yum-config-manager --enable remi-php71 && \
 yum update -y && \
 yum install -y php php-pdo php-posix php-gd php-sqlite3 php-xsl php-snmp php-cli php-zip && \
 php -v

RUN npm install -g bower && \
 php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
 HASH="$(wget -q -O - https://composer.github.io/installer.sig)" && \
 php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
 php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
 composer

## TODO update this to not include bower, as it is deprecated
RUN git clone https://github.com/howardjones/network-weathermap.git /opt/weathermap && \
 chmod +x /opt/weathermap/weathermap && \
 cd /opt/weathermap && \
 bower install --allow-root && \
 composer update --no-dev && \
 php /opt/weathermap/check.php

RUN mkdir /config && \
 mkdir /output && \
 rm -fv /tmp/*.*

COPY weathermap.php /opt/weathermap.php
VOLUME /config /output

WORKDIR /opt/weathermap
CMD ["php", "/opt/weathermap.php"]
