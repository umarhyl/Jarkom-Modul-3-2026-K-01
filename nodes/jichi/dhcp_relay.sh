#!/bin/sh

# Soal 3 & 10: Konfigurasi DHCP Relay pada router jichi
# Melayani permintaan DHCP dari Network 2 (eth2) dan Network 3 (eth3)
# menuju DHCP Server tengen (10.64.4.10) via eth4

apt-get update
apt-get install -y isc-dhcp-relay

cat <<EOF > /etc/default/isc-dhcp-relay
SERVERS="10.64.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

service isc-dhcp-relay restart
service isc-dhcp-relay status
