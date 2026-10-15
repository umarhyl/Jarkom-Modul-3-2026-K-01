cat << 'EOF' > /etc/nginx/sites-available/default
upstream api_cluster {
    server 10.64.4.5 weight=3; # IP nanami
    server 10.64.4.6 weight=1; # IP todo
}

server {
    listen 80;

    # Mempercayai header dari proxy Gojo (10.64.1.4)
    set_real_ip_from 10.64.1.4;
    real_ip_header X-Forwarded-For;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host api.shibuya.com; 
        
        # Meneruskan kembali IP klien yang sudah diverifikasi ke worker
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

service nginx restart