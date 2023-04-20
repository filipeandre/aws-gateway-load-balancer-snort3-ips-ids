#!/bin/sh
echo "Snort container started"
. /update-config.sh
mkdir -p /var/log/snort && chown -R snort:snort /var/log/snort
exec /bin/supervisord -c /supervisord.conf --nodaemon
