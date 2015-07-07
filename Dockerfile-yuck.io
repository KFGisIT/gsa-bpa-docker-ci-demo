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
env SITE_DB_PASSWORD njknjk345njkl34
env SITE_USER frontend
env SITE_DB_NAME frontend
env VIRTUALENV_SETUPTOOLS 1
env LANG C.UTF-8

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages.
RUN apt-get update
RUN apt-get install -y \
# for dev
        build-essential \
        git \
        openssh-server \
        aptitude \
# required
        python3-dev \
	python3 \
	python3-pip \
        python3-setuptools \
        nginx \
        sqlite3 \
        supervisor \
        vim \
        nodejs \
        npm \
        curl \
# for automatic security updates
        unattended-upgrades \
	apt-listchanges \
	mailutils 

# fix the path for node.js
RUN ln -s /usr/bin/nodejs /usr/bin/node 

RUN easy_install3 pip

#RUN pip3 install -U pip
#RUN pip3 install virtualenv
#RUN virtualenv /env
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y uwsgi uwsgi-plugin-python && \
    rm /etc/uwsgi/ -rf

ADD ./config/uwsgi.conf /etc/uwsgi.conf

RUN apt-get clean

# Install Composer.
#RUN curl -sS https://getcomposer.org/installer | php
#RUN mv composer.phar /usr/local/bin/composer

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


# Setup nginx as the supervised container process
RUN echo "daemon off;" >> /etc/nginx/nginx.conf &&\
  rm /etc/nginx/sites-enabled/default &&\
  ln -s /opt/django/django.conf /etc/nginx/sites-enabled/ &&\
  ln -s /opt/django/supervisord.conf /etc/supervisor/conf.d/

#RUN echo -e '[program:apache2]\ncommand=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"\nautorestart=true\n\n' >> /etc/supervisor/supervisord.conf
#RUN echo -e '[program:mysql]\ncommand=/usr/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/sbin/mysqld\nautorestart=true\n\n' >> /etc/supervisor/supervisord.conf
RUN echo -e '[program:sshd]\ncommand=/usr/sbin/sshd -D\n\n' >> /etc/supervisor/supervisord.conf
#RUN echo -e '[program:blackfire]\ncommand=/usr/local/bin/launch-blackfire\n\n' >> /etc/supervisor/supervisord.conf

# Setup Django, checkout project
ADD config/django-requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
#RUN /env/bin/pip3 install --upgrade setuptools
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.4 2
#RUN apt-get install --reinstall python-pkg-resources
ADD shared/yuck.io/ /opt/django/

WORKDIR /opt/django
#RUN source /env/bin/activate
#RUN source /opt/python/current/env
RUN git clone https://github.com/KFGisIT/gsa-bpa-django.git .
RUN npm install -g bower grunt-cli yuglify uglifyjs && cat bower.json 
RUN bower install --allow-root --config.interactive=false
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

EXPOSE 80 22 8000 5000
#CMD ["VOLUME ["/opt/django/app"]

# Build for uwsgi, if you want 
#CMD ["/usr/bin/uwsgi", "--ini", "/etc/uwsgi.conf"]

# bug with bower, collectstatic, and fonts
# workaround:
# https://github.com/brunch/brunch/issues/633 
RUN cp app/static/bower_components/bootstrap/fonts/* app/static/bower_components/select2/docs/vendor/fonts

#run directly, for development/debugging
RUN mkdir /opt/django/app/static/components && \ 
    python3 ./manage.py collectstatic --noinput 

#for debugging only
#CMD python3 ./manage.py runserver 0.0.0.0:5000


# Build for uwsgi+lightweight http, if you want 
CMD ["/usr/bin/uwsgi", "--ini", "/etc/uwsgi.conf"]


# ...or serve files with nginx

