#!/bin/bash

# 1. Buka blokir service
printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d

# 2. Update dan Install Nginx + PHP-FPM
apt-get update
apt-get install -y nginx php-fpm

# 3. Buat file index.php yang menampilkan hostname
rm /var/www/html/index.html 2>/dev/null
cat << 'EOF' > /var/www/html/index.php
<?php
echo "Ini adalah node: " . gethostname() . "\n";
?>
EOF

# 4. Konfigurasi Virtual Host dan Pembatasan Akses
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name web.shibuya.com;

    # Hanya menerima trafik melalui jalur proxy web yang ditentukan (Gojo)
    allow 10.64.1.4;
    deny all;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

# 5. Restart Service
service php*-fpm restart
service nginx restart

echo "Setup Web Worker Selesai!"