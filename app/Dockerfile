FROM trafex/php-nginx

WORKDIR /root
USER root
RUN apk update


# Install composer from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer

#Installation of utils
RUN apk add lsb-release ca-certificates wget zip vim

### PHP DEPENDENCIES ###
RUN apk add php83-pdo_mysql
RUN apk add php83-xml php83-curl php83-mbstring php83-zip php83-intl php83-gd php83-iconv
RUN apk add --no-cache php83-pear php83-dev gcc musl-dev make


### MONGODB ###
RUN pecl install apcu mongodb
RUN echo "extension=mongodb.so" >> /etc/php83/conf.d/settings.ini
RUN cat /etc/php83/conf.d/settings.ini


### NGINX ###
COPY nginx.conf /etc/nginx/conf.d/server.conf

#Copy of the project
COPY . /app
RUN chown -R nobody:nobody /app/
RUN chmod 777 -R /app/

#Installation of the project
WORKDIR /app
RUN apk add php83-simplexml
RUN composer update
#USER nobody
RUN composer install --no-dev --optimize-autoloader --no-scripts
RUN php bin/console cache:clear --env=prod
RUN composer dump-env prod
RUN composer dump-autoload --no-dev --classmap-authoritative
RUN php bin/console assets:install
USER root

#Service setup
COPY ./startup.sh /docker-entrypoint.d/startup.sh
RUN chmod u+x /docker-entrypoint.d/startup.sh
