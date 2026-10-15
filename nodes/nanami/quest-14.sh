#!/bin/bash
set -e

# 1. Buka blokir service Debian
printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d

# 2. Install Nginx, PHP-FPM, php-mysql
apt-get update
apt-get install -y nginx php-fpm php-mysql

# 3. File index.php pencatat log lengkap (Soal 14 & Soal 17)
rm -f /var/www/html/index.html
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

$hostname   = gethostname();
$client_ip  = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];
$proxy_ip   = $_SERVER['REMOTE_ADDR'];
$user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
$pesan      = "Request API berhasil diproses oleh node: " . $hostname;

$stmt = $conn->prepare("INSERT INTO request_logs (worker_name, client_ip, proxy_ip, user_agent, pesan) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("sssss", $hostname, $client_ip, $proxy_ip, $user_agent, $pesan);

if ($stmt->execute()) {
    echo json_encode([
        "status"      => "success",
        "worker_name" => $hostname,
        "client_ip"   => $client_ip,
        "proxy_ip"    => $proxy_ip,
        "message"     => "Log berhasil dicatat di database Yaga"
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mencatat log: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
EOF

# Support akses endpoint /api tanpa 404
ln -sf /var/www/html /var/www/html/api

# 4. Konfigurasi Nginx (Hanya izinkan Geto 10.64.4.2 dan localhost)
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name jujutsu.k01.com www.jujutsu.k01.com api.shibuya.com _;

    allow 10.64.4.2;
    allow 127.0.0.1;
    deny all;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

service php*-fpm restart
service nginx restart
echo "Setup API Worker Selesai!"