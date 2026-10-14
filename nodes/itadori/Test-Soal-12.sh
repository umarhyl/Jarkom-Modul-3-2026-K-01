dig @10.64.1.2 test-sync.jujutsu.k01.com ; utahime
dig @10.64.1.2 -x 10.64.1.4

echo "nameserver 10.64.1.2" > /etc/resolv.conf
ping -c 4 google.com