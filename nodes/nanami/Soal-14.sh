#!/bin/bash

# 1. Buka blokir service
printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d

# 2. Install Nginx, PHP-FPM, dan php-mysql
apt-get update
apt-get install -y nginx php-fpm php-mysql

# 3. Buat skrip API pencatat log ke database Yaga
rm /var/www/html/index.html 2>/dev/null
cat << 'EOF' > /var/www/html/index.php
<?php
header('Content-Type: application/json');

$host = '10.64.4.11';
$db   = 'db_shibuya_k01';
$user = 'admin_shibuya';
$pass = 'admin123';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Koneksi ke DB Yaga gagal: " . $conn->connect_error]);
    exit();
}

$hostname = gethostname();
$pesan = "Request API berhasil diproses oleh node backend: " . $hostname;
$sql = "INSERT INTO request_logs (pesan) VALUES ('$pesan')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Log berhasil dicatat di database Yaga oleh " . $hostname]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mencatat log: " . $conn->error]);
}
$conn->close();
?>
EOF

# 4. Konfigurasi Virtual Host dan Pembatasan Akses
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name api.shibuya.com;

    # Hanya menerima trafik melalui jalur proxy geto
    allow 10.64.4.2;
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

echo "Setup API Worker Selesai!"