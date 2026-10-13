#!/bin/sh

update-rc.d isc-dhcp-relay defaults 2>/dev/null

cat <<'EOF' > /etc/rc.local
#!/bin/sh -e
sh /root/init.sh
service isc-dhcp-relay start 2>/dev/null
dhcrelay -4 -i eth2 -i eth3 -i eth4 10.64.4.10 2>/dev/null
exit 0
EOF
chmod +x /etc/rc.local
