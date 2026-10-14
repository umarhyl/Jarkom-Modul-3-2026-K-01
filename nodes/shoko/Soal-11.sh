
apt-get update
apt-get install -y bind9 bind9utils
mkdir -p /etc/bind

cat <<EOF > /etc/bind/named.conf.local
zone "jujusu.k01.com" {
    type master;
    file "/etc/bind/db.jujutsu";
    primaries { 10.64.1.3; };
};
EOF

cat << 'EOF' > /etc/bind/db.jujutsu
$TTL    604800
@       IN      SOA     ns1.jujutsu.k01.com. admin.jujutsu.k01.com. (
                              2026101305 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL
;
@       IN      NS      ns1.jujutsu.k01.com.
@       IN      NS      ns2.jujutsu.k01.com.

ns1         IN      A       10.64.1.2
ns2         IN      A       10.64.1.3
www         IN      A       10.64.1.4
test-sync   IN      A       10.64.1.99 
EOF

service named restart || /etc/init.d/named restart || named