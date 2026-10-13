#!/bin/sh

# ========================================================
# Script Pengujian Soal 9 di jichi
# Simulasi Gangguan: Matikan Relay lalu Hidupkan Kembali
# ========================================================

ACTION=$1

if [ "$ACTION" = "stop" ]; then
    echo "Menghentikan DHCP Relay pada jichi..."
    service isc-dhcp-relay stop
    echo "Status Relay sekarang:"
    service isc-dhcp-relay status
elif [ "$ACTION" = "start" ]; then
    echo "Memulihkan kembali DHCP Relay pada jichi..."
    service isc-dhcp-relay start
    echo "Status Relay sekarang:"
    service isc-dhcp-relay status
else
    echo "Penggunaan: sh /root/test_soal9.sh [stop|start]"
fi
