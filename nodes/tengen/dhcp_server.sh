#!/bin/sh

# Soal 2, 4, 5, 6, 7: Konfigurasi DHCP Server pada tengen (10.64.4.10)
apt-get update
apt-get install -y isc-dhcp-server

# Interface yang mendengarkan DHCP request
cat <<EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

# File konfigurasi dhcpd.conf
cat <<'EOF' > /etc/dhcp/dhcpd.conf
# Global Options
option domain-name "k01.com";
option domain-name-servers 10.64.1.2, 10.64.1.3;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# ========================================================
# Soal 4: DHCP Classes untuk Network 2 (Divisi A)
# Berdasarkan MAC Address client
# ========================================================
class "dev-team" {
    match if (
        hardware = 01:02:42:10:96:32:00 or
        hardware = 01:02:42:82:01:ad:00
    );
}

class "support-team" {
    match if (
        hardware = 01:02:42:03:be:c4:00 or
        hardware = 01:02:42:7a:e9:57:00
    );
}

# ========================================================
# Soal 5: DHCP Classes untuk Network 3 (Divisi B)
# Short Lease vs Long Lease
# ========================================================
class "short-lease-clients" {
    match if (
        hardware = 01:02:42:8c:dc:78:00 or
        hardware = 01:02:42:4b:2b:85:00
    );
}

class "long-lease-clients" {
    match if (
        hardware = 01:02:42:39:9b:53:00
    );
}

# ========================================================
# Soal 2: Subnet Deklarasi Lokal (Network 4 - Data Center)
# Tanpa dynamic pool agar tidak error 'No subnet declaration'
# ========================================================
subnet 10.64.4.0 netmask 255.255.255.0 {
}

# ========================================================
# Network 2 (Divisi A) - Menggunakan Relay via eth2 jichi
# ========================================================
subnet 10.64.2.0 netmask 255.255.255.0 {
    option routers 10.64.2.1;
    option broadcast-address 10.64.2.255;
    option domain-name-servers 10.64.1.2, 10.64.1.3;
    option domain-name "k01.com";

    # Pool 1 (10.64.2.10 - 10.64.2.35) -> itadori & fushiguro
    pool {
        allow members of "dev-team";
        range 10.64.2.10 10.64.2.35;
    }

    # Pool 2 (10.64.2.70 - 10.64.2.95) -> zenin & okkotsu
    pool {
        allow members of "support-team";
        range 10.64.2.70 10.64.2.95;
    }
}

# ========================================================
# Network 3 (Divisi B) - Menggunakan Relay via eth3 jichi
# ========================================================
subnet 10.64.3.0 netmask 255.255.255.0 {
    option routers 10.64.3.1;
    option broadcast-address 10.64.3.255;
    option domain-name-servers 10.64.1.2, 10.64.1.3;
    option domain-name "k01.com";

    # Soal 5: Pool Short Lease (10.64.3.10 - 10.64.3.89)
    # Default: 1800 detik (30 mnt), Max: 1800 detik
    pool {
        allow members of "short-lease-clients";
        range 10.64.3.10 10.64.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Soal 5: Pool Long Lease (10.64.3.100 - 10.64.3.199)
    # Default: 43200 detik (12 jam), Max: 43200 detik
    pool {
        allow members of "long-lease-clients";
        range 10.64.3.100 10.64.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}

# ========================================================
# Soal 6: Fixed Address (Static Lease) untuk Kugisaki
# MAC: 02:42:91:6d:8c:00 -> IP: 10.64.3.99
# Berada di luar seluruh pool dinamis
# ========================================================
host kugisaki {
    hardware ethernet 02:42:91:6d:8c:00;
    fixed-address 10.64.3.99;
    option routers 10.64.3.1;
    option domain-name-servers 10.64.1.2, 10.64.1.3;
    option domain-name "k01.com";
}
EOF

# Restart isc-dhcp-server
service isc-dhcp-server restart
service isc-dhcp-server status
