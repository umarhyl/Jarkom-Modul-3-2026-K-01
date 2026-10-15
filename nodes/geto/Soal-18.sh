cat << 'EOF' > /etc/nginx/sites-available/default
upstream api_cluster {
    # Worker Utama dengan Passive Health Check
    server 10.64.4.5 weight=3 max_fails=2 fail_timeout=5s; # IP nanami
    server 10.64.4.6 weight=1 max_fails=2 fail_timeout=5s; # IP todo
    
    # Worker Cadangan
    server 10.64.4.7 backup; 
}

server {
    listen 80;

    set_real_ip_from 10.64.1.4;
    real_ip_header X-Forwarded-For;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host api.shibuya.com; 
        
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

service nginx restart