#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

killall udhcpc 2>/dev/null
udhcpc -i eth0 -n -q
