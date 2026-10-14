#!/bin/sh

apt-get update
apt-get install -y bind9 bind9utils
mkdir -p /etc/bind

cat <<EOF > /etc/bind/named.conf.local
zone "jujusu.k01.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu";
    primaries { 10.64.1.2; };
};
EOF

service named restart || /etc/init.d/named restart || named