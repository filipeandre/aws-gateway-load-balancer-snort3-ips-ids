#!/bin/bash

set -e

# Define variables
homenet=$HOMENET
oinkcode=$OINKCODE

# Enable logging
logger_info() {
    echo "$(date) $*"
}

logger_info "writing oinkcode ${oinkcode} to /usr/local/etc/pulledpork3/pulledpork.conf"
sed -i "s|^oinkcode = .*|oinkcode = ${oinkcode}|" /usr/local/etc/pulledpork3/pulledpork.conf

# Write Homenet to snort.lua
logger_info "writing homenet ${homenet} to /usr/local/etc/snort/snort.lua"
sed -i "s|^HOME_NET = .*|HOME_NET = '${homenet}'|" /usr/local/etc/snort/snort.lua