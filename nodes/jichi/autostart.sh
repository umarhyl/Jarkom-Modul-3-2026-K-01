#!/bin/sh

# ========================================================
# Script Soal 10 di jichi
# Autostart DHCP Relay setelah restart
# ========================================================

# Menambahkan ke rc.local atau update-rc.d
systemctl enable isc-dhcp-relay 2>/dev/null || update-rc.d isc-dhcp-relay defaults 2>/dev/null

# Memastikan /root/init.sh & /root/dhcp_relay.sh dijalankan saat boot
cat <<'EOF' > /etc/rc.local
#!/bin/sh -e
sh /root/init.sh
service isc-dhcp-relay start
exit 0
EOF
chmod +x /etc/rc.local

echo "Autostart DHCP Relay pada jichi telah dikonfigurasi."
