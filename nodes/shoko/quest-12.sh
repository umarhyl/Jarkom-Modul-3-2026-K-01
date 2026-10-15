#!/bin/bash

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

zone "1.64.10.in-addr.arpa" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/db.10.64.1";
};
EOF

named-checkconf

rndc reload || service named restart || /etc/init.d/named restart || named
