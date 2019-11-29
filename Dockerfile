FROM dropteam/drupal-php:7.1-apache
RUN docker-php-ext-install bcmath 
ADD core/ssmtp.conf /etc/ssmtp/ssmtp.conf