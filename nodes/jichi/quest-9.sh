#!/bin/sh

ACTION=$1

if [ "$ACTION" = "stop" ]; then
    pkill dhcrelay 2>/dev/null
    service isc-dhcp-relay stop 2>/dev/null
elif [ "$ACTION" = "start" ]; then
    service isc-dhcp-relay start 2>/dev/null
    dhcrelay -4 -i eth2 -i eth3 -i eth4 10.64.4.10 2>/dev/null
fi

service isc-dhcp-relay status 2>/dev/null
ps aux | grep dhcrelay
