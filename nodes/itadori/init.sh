#!/bin/sh

# Konfigurasi client DHCP Alpine Linux
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

# Jalankan DHCP client untuk meminta IP otomatis
killall udhcpc 2>/dev/null
udhcpc -i eth0 -n -q
