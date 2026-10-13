#!/bin/sh

cat /var/lib/dhcp/dhcpd.leases | grep -E "lease |hardware ethernet|binding state"

# Quest 8
# tcpdump -i eth0 -n -vvv "port 67 or port 68"
