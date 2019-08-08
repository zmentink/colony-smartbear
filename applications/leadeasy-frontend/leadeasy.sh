#!/usr/bin/env bash

echo "==> Installing apache web server"
apt-get update -y
apt-get python2
apt-get install apache2 -y
service apache2 stop

echo "==> Installing python 2.7"
apt-get install python-minimal -y
apt-get update -y
apt install python-pip -y

echo "==> Installing apache-flash plugin"
apt-get install libapache2-mod-wsgi python-dev -y
a2enmod wsgi

echo "==> Installing flask and additional python requirements"
pip install Flask
pip install requests

echo '==> Extract artifact to /var/leads-webapp/'
mkdir /var/leads-webapp/
tar -xvf $ARTIFACTS_PATH/leads-webapp.*.tar.gz -C /var/leads-webapp/

# make sure init file exists and if not create it
if [ -f "/var/leads-webapp/__init__.py" ]
then
    echo ''
else
    touch /var/leads-webapp/__init__.py
fi

echo '==> Create flask wsgi file'
touch /var/leads-webapp/leads_webapp.wsgi
cat << EOF > /var/leads-webapp/leads_webapp.wsgi
#! /usr/bin/python
import logging
import sys
import os

logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, '/var/leads-webapp/')

def application(req_environ, start_response):
    
    for key in req_environ:
        if key.startswith('SALESFORCE_'):
            os.environ[key] = req_environ[key]

    ## has to import my app inside of application def block.
    from leads_webapp import app as _application

    return _application(req_environ, start_response)
EOF

echo '==> Add 755 permissions on /var/leads-webapp/'
chmod 755 /var
chmod 755 /var/leads-webapp

echo '==> Configure apache'
mv /etc/apache2/sites-available/ /etc/apache2/sites-available-old/
mkdir /etc/apache2/sites-available/
chmod 755 /etc/apache2/sites-available/
touch /etc/apache2/sites-available/leads-webapp.conf
cat << EOF > /etc/apache2/sites-available/leads-webapp.conf
<VirtualHost *:80>     
     # Give an alias to to start your website url with
     WSGIDaemonProcess leads_webapp user=www-data group=www-data threads=5
     WSGIProcessGroup leads_webapp
     WSGIScriptAlias / /var/leads-webapp/leads_webapp.wsgi

     SetEnv SALESFORCE_LOGIN_URL $SALESFORCE_LOGIN_URL
     SetEnv SALESFORCE_CLIENT_ID $SALESFORCE_CLIENT_ID
     SetEnv SALESFORCE_CLIENT_SECRET $SALESFORCE_CLIENT_SECRET
     SetEnv SALESFORCE_USERNAME $SALESFORCE_USERNAME
     SetEnv SALESFORCE_PASSWORD $SALESFORCE_PASSWORD

     <Directory /var/leads-webapp/>
                # set permissions as per apache2.conf file
            Options FollowSymLinks
            AllowOverride None
            Require all granted
     </Directory>
     ErrorLog /var/log/apache2/leads_webapp_error.log
     LogLevel warn
     CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

echo "==> enable leads-webapp flask app"
a2ensite leads-webapp
ufw allow 'Apache Full'
service apache2 start
service apache2 reload