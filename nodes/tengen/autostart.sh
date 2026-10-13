#!/bin/sh

# ========================================================
# Script Soal 10 di tengen
# Autostart DHCP Server setelah restart
# ========================================================

systemctl enable isc-dhcp-server 2>/dev/null || update-rc.d isc-dhcp-server defaults 2>/dev/null

cat <<'EOF' > /etc/rc.local
#!/bin/sh -e
sh /root/init.sh
service isc-dhcp-server start
exit 0
EOF
chmod +x /etc/rc.local

echo "Autostart DHCP Server pada tengen telah dikonfigurasi."
