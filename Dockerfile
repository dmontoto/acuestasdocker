FROM eboraas/debian:stable
MAINTAINER Ed Boraas <ed@boraas.ca>

# Apache configuration
RUN apt-get update && apt-get -y install apache2 && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN /usr/sbin/a2ensite default-ssl
RUN /usr/sbin/a2enmod ssl

# PHP Configuration
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get -y install php php-mysql && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /usr/sbin/a2enmod php7.0

# Laravel configuration
RUN apt-get update && apt-get -y install git curl php-mcrypt php-json && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /usr/sbin/a2enmod rewrite
ADD 000-laravel.conf /etc/apache2/sites-available/
ADD 001-laravel-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-laravel 001-laravel-ssl
RUN /usr/bin/curl -sS https://getcomposer.org/installer |/usr/bin/php
RUN /bin/mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer create-project laravel/laravel /var/www/laravel 4.2 --prefer-dist
RUN mkdir /var/www/laravel/bootstrap/cache
RUN /bin/chown www-data:www-data -R /var/www/laravel/app/storage /var/www/laravel/bootstrap/cache

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]