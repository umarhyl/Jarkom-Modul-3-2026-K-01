#!/bin/bash

# 1. Buka blokir service dan install Nginx
printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d
apt-get update
apt-get install -y nginx

# 2. Konfigurasi Nginx untuk Path-Based Routing
cat << 'EOF' > /etc/nginx/sites-available/default
# Upstream untuk Web Worker (Default-nya adalah Round Robin)
upstream web_frontend {
    server 10.64.4.3;  
    server 10.64.4.4; 
}

server {
    listen 80;
    
    server_name jujutsu.k01.com www.jujutsu.k01.com;

    # Routing 1: Request root (/) diteruskan ke maki dan panda
    location / {
        proxy_pass http://web_frontend;
        
        # Meneruskan header Host agar dikenali oleh Virtual Host di maki/panda
        proxy_set_header Host web.shibuya.com; 
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Routing 2: Request /api diteruskan langsung ke geto (10.64.4.2)
    location /api {
        proxy_pass http://10.64.4.2/;
        
        # Meneruskan header Host agar dikenali oleh Virtual Host di Geto
        proxy_set_header Host api.shibuya.com;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# 3. Restart Nginx
service nginx restart
echo "Setup Path-Based Routing di Gojo Selesai!"