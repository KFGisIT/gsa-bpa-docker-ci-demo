#!/bin/bash
MYSQL_ROOT_PASSWORD=`openssl rand -base64 15`

mysql -u root -e " \
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root'; \
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
DELETE FROM mysql.user WHERE User=''; \
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; \
FLUSH PRIVILEGES; \
"

echo "[client]" >> /root/.my.cnf
echo "user = root" >> /root/.my.cnf
echo "password=\"$MYSQL_ROOT_PASSWORD\"" >> /root/.my.cnf

echo "MySQL (or MariaDB) root pw set to: $MYSQL_ROOT_PASSWORD"
echo "... also saved root pw to /root/.my.cnf "



