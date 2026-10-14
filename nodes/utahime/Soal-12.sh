#!/bin/bash

cat << 'EOF' > /etc/bind/db.jujutsu
@       IN      SOA     ns1.jujutsu.k01.com. admin.jujutsu.k01.com. (
                              2026101401 ; Serial
                              604800
                              86400
                              2419200
                              604800 )
;
@       IN      NS      ns1.jujutsu.k01.com.
@       IN      NS      ns2.jujutsu.k01.com.

ns1         IN      A       10.64.1.2
ns2         IN      A       10.64.1.3
@           IN      A       10.64.1.4
www         IN      CNAME   jujutsu.k01.com.
test-sync   IN      A       10.64.1.99
EOF

cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.k01.com" {
    type master;
    file "/etc/bind/db.jujutsu";
    allow-transfer { 10.64.1.3; };
};

zone "1.64.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10";
    allow-transfer { 10.64.1.3; };
};
EOF

cat << 'EOF' > /etc/bind/db.10
$TTL    604800
@       IN      SOA     ns1.jujutsu.k01.com. admin.jujutsu.k01.com. (
                              2026101401 ; Serial
                              604800
                              86400
                              2419200
                              604800 )
;
@       IN      NS      ns1.jujutsu.k01.com.
@       IN      NS      ns2.jujutsu.k01.com.

4       IN      PTR     jujutsu.k01.com.
EOF

cat << 'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };
    
    recursion yes;
    allow-query { any; };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF

named-checkconf
named-checkzone jujutsu.k01.com /etc/bind/db.jujutsu
named-checkzone 1.64.10.in-addr.arpa /etc/bind/db.10

service named restart || /etc/init.d/named restart || named