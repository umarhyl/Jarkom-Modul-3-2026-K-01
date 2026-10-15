#!/bin/sh

# ==========================================
# Quest 2: Instalasi & Interface DHCP Server
# ==========================================
apt-get update
apt-get install -y isc-dhcp-server

cat <<EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

cat <<'EOF' > /etc/dhcp/dhcpd.conf
# Quest 7
option domain-name "k01.com";
option domain-name-servers 10.64.1.2, 10.64.1.3;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Quest 4
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

# Quest 5
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

# Quest 2
subnet 10.64.4.0 netmask 255.255.255.0 {
}

# Quest 4
subnet 10.64.2.0 netmask 255.255.255.0 {
    option routers 10.64.2.1;
    option broadcast-address 10.64.2.255;
    option domain-name-servers 10.64.1.2, 10.64.1.3;
    option domain-name "k01.com";

    # Dev Team (Itadori, Fushiguro): 10.64.2.10 - 10.64.2.35
    pool {
        allow members of "dev-team";
        range 10.64.2.10 10.64.2.35;
    }

    # Support Team (Zenin, Okkotsu): 10.64.2.70 - 10.64.2.95
    pool {
        allow members of "support-team";
        range 10.64.2.70 10.64.2.95;
    }
}

# Quest 5
subnet 10.64.3.0 netmask 255.255.255.0 {
    option routers 10.64.3.1;
    option broadcast-address 10.64.3.255;
    option domain-name-servers 10.64.1.2, 10.64.1.3;
    option domain-name "k01.com";

    # Short Lease 30 menit (Ino, Kusakabe): 10.64.3.10 - 10.64.3.89
    pool {
        allow members of "short-lease-clients";
        range 10.64.3.10 10.64.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Long Lease 12 jam (Miwa): 10.64.3.100 - 10.64.3.199
    pool {
        allow members of "long-lease-clients";
        range 10.64.3.100 10.64.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}

# Quest 6
host kugisaki {
    hardware ethernet 02:42:91:6d:8c:00;
    fixed-address 10.64.3.99;
    option routers 10.64.3.1;
    option domain-name-servers 10.64.1.2, 10.64.1.3;
    option domain-name "k01.com";
}
EOF

service isc-dhcp-server restart