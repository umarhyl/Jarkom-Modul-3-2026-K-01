cat << 'EOF' > /etc/nginx/sites-available/default
upstream web_frontend {
    server 10.64.4.3; # IP maki
    server 10.64.4.4; # IP panda
}

server {
    listen 80;
    
    server_name jujutsu.k01.com www.jujutsu.k01.com; 

    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host web.shibuya.com; 
        
        # Meneruskan IP Klien
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api {
        proxy_pass http://10.64.4.2/;
        proxy_set_header Host api.shibuya.com;
        
        # Meneruskan IP Klien
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

service nginx restart