#!/usr/bin/env bash

# Need for PHP 7.1+
sudo add-apt-repository ppa:ondrej/php

sudo apt-get update
sudo apt-get install -y apache2

touch /etc/apache2/sites-available/mysite.conf
cat << EOF | sudo tee -a /etc/apache2/sites-available/mysite.conf
<VirtualHost *:80>
  ServerName mysite.vm
  ServerAlias *.mysite.vm
  DirectoryIndex index.php index.html
  DocumentRoot /var/www/public
    <Directory /var/www/public/ >
      Options Indexes FollowSymLinks
      AllowOverride All
      Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2dissite 000-default.conf
sudo a2ensite mysite.conf
sudo a2enmod rewrite actions

sudo apt-get install -y php7.2 php7.2-curl php7.2-xml php7.2-zip php7.2-gd php7.2-mysql php7.2-mbstring php-xdebug

# MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y mysql-server mysql-client
mysql -u root -proot -e "CREATE DATABASE mydb"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION"
sed -i '/bind-address/c #bind-address = 127.0.0.1' /etc/mysql/my.cnf

# Install Composer
echo "Installing Composer"
echo "------------------------"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

sudo apt-get install -y libapache2-mod-php7.2
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork

sudo apt-get install nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install yarn


# Cleanup
sudo apt-get -y autoremove
sudo apt-get clean

sudo service apache2 restart


