#!/bin/bash
set -x #shows execution of each command 
set -e #terminates the process and exit if one command fails
sudo apt update
sudo apt install -y nginx php-fpm php-mysql unzip mysql-client
sudo wget -O /tmp/latest.zip https://wordpress.org/latest.zip
sudo unzip  /tmp/latest.zip -d /tmp
sudo mv /tmp/wordpress /var/www/html
sudo rm -f /etc/nginx/sites-enabled/default

sudo cat > /etc/nginx/sites-enabled/wp.conf << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html/wordpress;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name _;
    location / {
        try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }
}
EOF

sudo nginx -s reload
sudo service php8.1-fpm reload
