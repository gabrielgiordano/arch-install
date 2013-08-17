#!/usr/bin/env bash

groupadd pdnsd
useradd -r -d /var/cache/pdnsd -g pdnsd -s /bin/false pdnsd
chown -R pdnsd:pdnsd /var/cache/pdnsd
chmod 700 /var/cache/pdnsd
chmod 600 /var/cache/pdnsd/pdnsd.cache
systemctl enable pdnsd