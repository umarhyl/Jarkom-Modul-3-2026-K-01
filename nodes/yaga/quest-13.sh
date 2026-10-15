#!/bin/bash
set -e

apt-get update
apt-get install -y mariadb-server

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Konfigurasi bind-address, server-id, dan binary logging di 50-server.cnf
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/^#*server-id\s*=.*/server-id = 1/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's|^#*log_bin\s*=.*|log_bin = /var/log/mysql/mariadb-bin.log|' /etc/mysql/mariadb.conf.d/50-server.cnf

grep -q "server-id = 1" /etc/mysql/mariadb.conf.d/50-server.cnf || sed -i '/\[mysqld\]/a server-id = 1\nlog_bin = /var/log/mysql/mariadb-bin.log\nbinlog_do_db = db_shibuya_k01' /etc/mysql/mariadb.conf.d/50-server.cnf
grep -q "binlog_do_db = db_shibuya_k01" /etc/mysql/mariadb.conf.d/50-server.cnf || sed -i '/log_bin =/a binlog_do_db = db_shibuya_k01' /etc/mysql/mariadb.conf.d/50-server.cnf

service mariadb restart

# Inisialisasi database, tabel request_logs, user replikasi & remote Network 4
mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS db_shibuya_k01;
USE db_shibuya_k01;

DROP TABLE IF EXISTS request_logs;
CREATE TABLE request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    worker_name VARCHAR(50),
    client_ip VARCHAR(50),
    proxy_ip VARCHAR(50),
    user_agent TEXT,
    pesan VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User untuk replikasi slave
CREATE USER IF NOT EXISTS 'replica'@'%' IDENTIFIED BY 'replica123';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replica'@'%';

-- Hak akses remote bagi seluruh node di Network 4 (10.64.4.%)
CREATE USER IF NOT EXISTS 'admin_shibuya'@'10.64.4.%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON db_shibuya_k01.* TO 'admin_shibuya'@'10.64.4.%';
CREATE USER IF NOT EXISTS 'root'@'10.64.4.%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.64.4.%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

echo "=== Yaga DB Master Status ==="
mariadb -u root -e "SHOW MASTER STATUS\G"
