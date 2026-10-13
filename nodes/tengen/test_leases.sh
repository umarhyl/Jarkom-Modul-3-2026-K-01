#!/bin/sh

# ========================================================
# Script Pengujian Soal 7 & 8 di tengen
# ========================================================

echo "=== DAFTAR LEASE SAAT INI (/var/lib/dhcp/dhcpd.leases) ==="
cat /var/lib/dhcp/dhcpd.leases | grep -E "lease |hardware ethernet|binding state"

echo ""
echo "=== STATUS ISC-DHCP-SERVER ==="
service isc-dhcp-server status

# Soal 8: Packet capture DHCP (DORA)
# tcpdump -i eth0 -n -vvv "port 67 or port 68" -c 10
