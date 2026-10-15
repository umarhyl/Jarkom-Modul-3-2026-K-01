#!/bin/bash
set -e

# 1. Buka blokir service Debian
printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d

# 2. Install Nginx + PHP-FPM
apt-get update
apt-get install -y nginx php-fpm

# 3. File index.php menampilkan hostname
rm -f /var/www/html/index.html
cat << 'EOF' > /var/www/html/index.php
<?php
echo "Response dari Frontend Worker: " . gethostname() . "\n";
?>
EOF

# 4. Konfigurasi Nginx (Hanya izinkan Gojo 10.64.1.4 dan localhost)
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name jujutsu.k01.com www.jujutsu.k01.com web.shibuya.com _;

    allow 10.64.1.4;
    allow 127.0.0.1;
    deny all;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

service php*-fpm restart
service nginx restart
echo "Setup Web Worker Selesai!"