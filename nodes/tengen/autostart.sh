#!/bin/sh

update-rc.d isc-dhcp-server defaults 2>/dev/null

cat <<'EOF' > /etc/rc.local
#!/bin/sh -e
sh /root/init.sh
service isc-dhcp-server start 2>/dev/null
exit 0
EOF
chmod +x /etc/rc.local
