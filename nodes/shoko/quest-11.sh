#!/bin/bash

apt-get update
apt-get install -y bind9 bind9utils
mkdir -p /etc/bind

cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};
EOF

cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.k01.com" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/db.jujutsu";
};
EOF

named-checkconf

service named restart || /etc/init.d/named restart || named