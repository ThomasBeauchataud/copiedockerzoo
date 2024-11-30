FROM nginx:latest

WORKDIR /root
RUN apt update

# Installation of utils
RUN apt install -y lsb-release apt-transport-https ca-certificates wget zip vim

# Installation of PHP / Composer
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" |tee /etc/apt/sources.list.d/php.list
RUN apt install -y php8.2-fpm php8.2-mysql
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN apt -y install php8.2-xml php8.2-curl php8.2-mbstring php8.2-zip php8.2-intl php8.2-gd php8.2-iconv php8.2-simplexml
RUN mkdir -p /run/php/ && rm /etc/nginx/conf.d/default.conf
RUN echo "listen.owner = nginx" >>/etc/php/8.2/fpm/php-fpm.conf
RUN echo "listen.group = nginx" >>/etc/php/8.2/fpm/php-fpm.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

### PHP DEPENDENCIES ###
RUN apt install -y php-pear php-dev gcc musl-dev make

### MONGODB ###
RUN pecl install apcu mongodb
RUN echo "extension=mongodb.so" >> /etc/php/8.2/fpm/php.ini
RUN echo "extension=mongodb.so" >> /etc/php/8.2/cli/php.ini

### NGINX ###
COPY nginx.conf /etc/nginx/conf.d/default.conf

#Copy of the project
COPY . /app
RUN chown -R www-data:www-data /app/
RUN chmod 777 -R /app/

#Installation of the project
WORKDIR /app
USER www-data
RUN composer update
RUN composer install --optimize-autoloader --no-scripts
RUN php bin/console cache:clear
RUN php bin/console assets:install

USER root
#Service setup
COPY ./startup.sh /docker-entrypoint.d/startup.sh
RUN chmod u+x /docker-entrypoint.d/startup.sh
