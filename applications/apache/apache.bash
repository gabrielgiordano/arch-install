#!/usr/bin/env bash

mkdir "/home/${userName}/public_html"
chmod o+x "/home/${userName}"
chmod o+x "/home/${userName}/public_html"

if [[ -d /srv/http/phpMyAdmin ]] || [[ -d /srv/http/phpMyAdmin ]]; then
    rm -r /srv/http/phpMyAdmin    
fi
cp /etc/webapps/phpmyadmin/apache.example.conf /etc/httpd/conf/extra/httpd-phpmyadmin.conf
mysql -u root -p < /usr/share/webapps/phpMyAdmin/examples/create_tables.sql
