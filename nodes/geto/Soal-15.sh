#!/bin/bash

# 1. Buka blokir service dan install Nginx
printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d
apt-get update
apt-get install -y nginx

# 2. Konfigurasi Nginx sebagai Load Balancer dengan Weighted Round Robin (3:1)
cat << 'EOF' > /etc/nginx/sites-available/default
upstream api_cluster {
    server 10.64.4.5 weight=3; # IP nanami
    server 10.64.4.6 weight=1; # IP todo
}

server {
    listen 80;

    location / {
        proxy_pass http://api_cluster;
        
        # Meneruskan header Host agar Worker mengenali domainnya
        proxy_set_header Host api.shibuya.com; 
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# 3. Restart Nginx
service nginx restart
echo "Konfigurasi Load Balancer Geto Selesai!"