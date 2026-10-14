# Quest 3: DHCP relay

apt-get update
apt-get install -y isc-dhcp-relay

cat <<EOF > /etc/default/isc-dhcp-relay
SERVERS="10.64.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

service isc-dhcp-relay restart
pkill dhcrelay 2>/dev/null || true
dhcrelay -4 -i eth2 -i eth3 -i eth4 10.64.4.10 >/var/log/dhcrelay.log 2>&1 &