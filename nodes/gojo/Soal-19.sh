#!/bin/bash

# Buat direktori cache dan atur perizinannya
mkdir -p /var/cache/nginx
chown -R www-data:www-data /var/cache/nginx

# Tulis konfigurasi baru Nginx
cat << 'EOF' > /etc/nginx/sites-available/default
# Konfigurasi Direktori Cache (Zona web_cache)
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=web_cache:10m max_size=100m inactive=60m use_temp_path=off;

# Konfigurasi Rate Limiting (Zona api_limit, 10 request per detik)
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

upstream web_frontend {
    server 10.64.4.3; # IP maki
    server 10.64.4.4; # IP panda
}

server {
    listen 80;
    server_name jujutsu.k01.com www.jujutsu.k01.com; 

    # Routing Web dengan Proxy Caching
    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host web.shibuya.com; 
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Aktifkan Caching
        proxy_cache web_cache;
        proxy_cache_valid 200 302 10m; # Masa berlaku cache 10 menit
        add_header X-Cache-Status $upstream_cache_status; # Header status cache
    }

    # Routing API dengan Rate Limiting
    location /api {
        proxy_pass http://10.64.4.2/;
        proxy_set_header Host api.shibuya.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Aktifkan Rate Limiting (batas terlampaui akan menghasilkan error 503)
        limit_req zone=api_limit;
    }
}
EOF

# Restart Nginx
service nginx restart
echo "Konfigurasi Caching dan Rate Limiting di Gojo Selesai!"