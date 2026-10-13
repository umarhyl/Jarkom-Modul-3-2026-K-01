#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.4.10
    netmask 255.255.255.0
    gateway 10.64.4.1
EOF

cat <<EOF > /etc/resolv.conf
nameserver 192.168.122.1
EOF
