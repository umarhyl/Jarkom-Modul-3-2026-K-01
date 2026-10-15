#!/bin/sh
dig @10.64.1.2 jujutsu.k01.com
dig @10.64.1.2 www.jujutsu.k01.com
dig @10.64.1.2 -x 10.64.1.4

echo "nameserver 10.64.1.2" > /etc/resolv.conf
ping -c 4 google.com