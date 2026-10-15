#!/bin/bash
set -e

apt-get update
apt-get install -y mariadb-server

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Konfigurasi bind-address dan server-id pada slave
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/^#*server-id\s*=.*/server-id = 2/' /etc/mysql/mariadb.conf.d/50-server.cnf
grep -q "server-id = 2" /etc/mysql/mariadb.conf.d/50-server.cnf || sed -i '/\[mysqld\]/a server-id = 2' /etc/mysql/mariadb.conf.d/50-server.cnf

service mariadb restart

# Ambil File dan Position dari Master yaga (10.64.4.11)
MASTER_IP="10.64.4.11"
STATUS_OUT=$(mariadb -h "$MASTER_IP" -u replica -preplica123 -e "SHOW MASTER STATUS\G")
LOG_FILE=$(echo "$STATUS_OUT" | grep "File:" | awk '{print $2}')
LOG_POS=$(echo "$STATUS_OUT" | grep "Position:" | awk '{print $2}')

echo "Master Log File: $LOG_FILE, Position: $LOG_POS"

mariadb -u root <<EOF
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='$MASTER_IP',
    MASTER_USER='replica',
    MASTER_PASSWORD='replica123',
    MASTER_LOG_FILE='$LOG_FILE',
    MASTER_LOG_POS=$LOG_POS;
START SLAVE;
EOF

echo "=== Inumaki DB Slave Status ==="
mariadb -u root -e "SHOW SLAVE STATUS\G" | grep -E "Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master|Last_IO_Error|Last_SQL_Error"
