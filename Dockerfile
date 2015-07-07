#While we're waiting for CoreOS, we'll just use Debian Jessie
FROM debian:jessie
MAINTAINER Wendell Wilson <wwilson@kfgisit.com>
ENV DEBIAN_FRONTEND noninteractive
# Recieve email notices about this container 
# e.g. unattended security update results,
# packages that need updating
ENV YOUR_EMAIL w@wwbtc.com

# the mysql root password is randomly generated
# and stored in .my.cnf in /root 
# however, the mysql password for the site 
# can be specified here. It only has permissions
# to the local drupal frontend
# TODO: Randomly generate this since it can be 
#  read from sites/default/settings.php
env DRUPAL_SITE_DB_PASSWORD njknjk345njkl34
env DRUPAL_SITE_USER frontend
env DRUPAL_SITE_DB_NAME frontend

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages.
RUN apt-get update
RUN apt-get install -y \
	vim \
	git \
	apache2 \
	php-apc \
        libapache2-mod-php5 \
	php5-cli \
	php5-mysql \
	php5-gd \
	php5-curl \
#	libapache2-mod-php5 \
	curl \
	mysql-server \
	mysql-client \
	openssh-server \
	phpmyadmin \
	wget \
	supervisor \
# for automatic security updates
 	unattended-upgrades \
	apt-listchanges \
	mailutils \
# for Development inside the container
	vim	\
	aptitude

RUN apt-get clean

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush 7.
RUN composer global require drush/drush:7.*
RUN composer global update

# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Setup PHP.
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php5/apache2/php.ini
# PHP CLI.
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/cli/php.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php5/cli/php.ini

# Setup Blackfire
#RUN wget -O - https://packagecloud.io/gpg.key | apt-key add -
#RUN echo "deb http://packages.blackfire.io/debian any main" > /etc/apt/sources.list.d/blackfire.list
#RUN apt-get update
#RUN apt-get install -y blackfire-agent blackfire-php
#RUN echo -e '#!/bin/bash\n\
#if [[ -z "$BLACKFIREIO_SERVER_ID" || -z "$BLACKFIREIO_SERVER_TOKEN" ]]; then\n\
#    while true; do\n\
#        sleep 1000\n\
#    done\n\
#else\n\
#c    /usr/bin/blackfire-agent -server-id="$BLACKFIREIO_SERVER_ID" -server-token="$BLACKFIREIO_SERVER_TOKEN"\n\
#fi\n\
#' > /usr/local/bin/launch-blackfire
#RUN chmod +x /usr/local/bin/launch-blackfire
#RUN mkdir -p /var/run/blackfire

# Setup Apache.
# In order to run our Simpletest tests, we need to make Apache
# listen on the same port as the one we forwarded. Because we use
# 8080 by default, we set it up for that port.
#RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i -r '163,$s/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN echo "Listen 8080" >> /etc/apache2/ports.conf
RUN sed -i 's/VirtualHost *:80/VirtualHost */' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Setup PHPMyAdmin
RUN echo -e "\n# Include PHPMyAdmin configuration\nInclude /etc/phpmyadmin/apache.conf\n" >> /etc/apache2/apache2.conf
RUN sed -i -e "s/\/\/ \$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\]/\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\]/g" /etc/phpmyadmin/config.inc.php

# Setup MySQL, copy default mysql config, bind on all addresses, secure install.
COPY config/mysql/my.cnf /etc/mysql/my.cnf
COPY scripts/docker_mysql_secure_installation.sh /root/docker_mysql_secure_installation.sh
RUN chmod 0755 /root/docker_mysql_secure_installation.sh
RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/mysql/my.cnf
RUN /etc/init.d/mysql start && \ 
    mysql -u root -e "create database $DRUPAL_SITE_DB_NAME; grant all on $DRUPAL_SITE_DB_NAME.* to '$DRUPAL_SITE_USER'@'localhost' identified by \"$DRUPAL_SITE_DB_PASSWORD\"; flush privileges;" 


# Setup SSH.
# NOTE: SSH is usually NOT needed in PRODUCTION enviornments!
# Use these two commands to manually specify a password
#  RUN echo 'root:PleaseDontDoThis' | chpasswd
#  RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#  RUN mkdir -p /root/.ssh/ && touch /root/.ssh/authorized_keys
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# This file missing for you? It's different on every system. 
# It's part of passwordless SSH authentication; it's meant to contain YOUR public SSH key.  
# Use the helper docker_ssh_auth script to help you generate the authorized_keys 
# if you don't know what's needed. 
ADD authorized_keys /root/.ssh/authorized_keys
RUN chmod 0700 /root/.ssh && chmod 0600 /root/.ssh/authorized_keys

# Setup Unattended Upgrades/Updates (security only)
ADD config/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
RUN echo "Unattended-Upgrade::Mail \"$YOUR_EMAIL\";" >> /etc/apt/apt.conf.d/50unattended-upgrades

# Setup Supervisor.
RUN echo -e '[program:apache2]\ncommand=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"\nautorestart=true\n\n' >> /etc/supervisor/supervisord.conf
RUN echo -e '[program:mysql]\ncommand=/usr/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/sbin/mysqld\nautorestart=true\n\n' >> /etc/supervisor/supervisord.conf
RUN echo -e '[program:sshd]\ncommand=/usr/sbin/sshd -D\n\n' >> /etc/supervisor/supervisord.conf
#RUN echo -e '[program:blackfire]\ncommand=/usr/local/bin/launch-blackfire\n\n' >> /etc/supervisor/supervisord.conf

# Install Drupal.
RUN rm -rf /var/www

# RUN /etc/init.d/mysql restart 

# WORKDIR bug with drush CVE-19382 
# Vanilla Drupal -- pick this or the non-vanilla front-end below
# RUN cd /var && \
#	drush dl drupal && \
#	mv /var/drupal* /var/www

# Non-Vanilla Drupal frontend 
WORKDIR /var/www
# TODO: This should not be necessary; this is a pre-seeded database with some extra features. Wrap these up in a module properly.
ADD shared/mysql/drupal18f.txt /tmp/drupal18f.txt
RUN    echo "Setting up Frontend with this command:  drush site-install -y dkan --db-url=mysql://$DRUPAL_SITE_USER:$DRUPAL_SITE_DB_PASSWORD@localhost/$DRUPAL_SITE_DB_NAME  "
RUN    mkdir html && git clone --branch master  https://github.com/KFGisIT/gsa-bpa-drupal.git html && \
       cd html && /etc/init.d/mysql start && drush  site-install -y dkan --db-url="mysql://$DRUPAL_SITE_USER:$DRUPAL_SITE_DB_PASSWORD@localhost/$DRUPAL_SITE_DB_NAME" --account-name=admin --account-pass=admin && drush dl feeds_jsonpath_parser d3 feeds_ex feeds_tamper node_export && drush en -y d3 node_export node_export_features d3_views feeds_ex feeds_ui feeds_tamper feeds_tamper_ui uuid_path php && drush uuid-create-missing -y && drush en -y custom_18f && drush cc all && drush sql-cli < /tmp/drupal18f.txt && /root/docker_mysql_secure_installation.sh

# misc tweaks
#WORKDIR /var/www/html
#RUN mkdir -p /var/www/htmlsites/default/files && \
#	chmod a+w /var/www/html/sites/default -R && \
#	mkdir /var/www/html/sites/all/modules/contrib -p && \
#	mkdir /var/www/html/sites/all/modules/custom && \
#	mkdir /var/www/html/sites/all/themes/contrib -p && \
#	mkdir /var/www/html/sites/all/themes/custom && \
#	chown -R www-data:www-data /var/www/html/
	
#        drush dl admin_menu devel && \
#	drush en -y admin_menu simpletest && \
#	drush vset "admin_menu_tweak_modules" 1


# secure drupal install, drop privileges. 
#RUN /etc/init.d/mysql start && /root/docker_mysql_secure_installation.sh
env APACHE_RUN_USER    www-data
env APACHE_RUN_GROUP   www-data
ADD scripts/docker_secure_drupal.sh /tmp/docker_secure_drupal.sh
RUN /tmp/docker_secure_drupal.sh /var/www/html

EXPOSE 80 8080 3306 22
CMD exec supervisord -n

