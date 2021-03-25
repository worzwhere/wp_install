#!/bin/sh

# Installing Apache 2.4 Web Server
sudo add-apt-repository ppa:ondrej/apache2
sudo apt update
sudo apt-get install apache2 -y

# Installing PHP 7.2 for WordPress
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php7.2
sudo apt install -y libapache2-mod-php7.2 \
                    php7.2-common php7.2-mbstring \
                    php7.2-xmlrpc php7.2-gd \
                    php7.2-xml php7.2-mysql \
                    php7.2-cli php7.2-zip \
                    php7.2-curl php-imagick

# Changes parameters from php.ini configuration file
sudo mv /etc/php/7.2/apache2/php.ini php_bak.ini
sudo cp php.ini /etc/php/7.2/apache2/php.ini

# Installing MySQL Server for WordPress
sudo apt-get install -y mysql-server

# Installing latest WordPress on Ubuntu Server
cd /tmp && wget https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
sudo mv wordpress /var/www/wordpress
cd /var/www/wordpress/
sudo cp wp-config-sample.php wp-config.php
cat <<EOF > .htaccess
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
EOF

# Changing Ownership and Permission for WordPress files
sudo chown -R www-data:www-data /var/www/wordpress
sudo find /var/www/wordpress/ -type d -exec chmod 755 {} \;
sudo find /var/www/wordpress/ -type f -exec chmod 644 {} \;
sudo chmod 600 /var/www/wordpress/wp-config.php
sudo chmod 600 /var/www/wordpress/.htaccess

# Creating Apache Virtual Host for WordPress
cd /etc/apache2/sites-available
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
cat <<EOF > wordpress.conf
<VirtualHost *:80>
     ServerAdmin admin@example.com
     DocumentRoot /var/www/wordpress
     ServerName example.com
     ServerAlias www.example.com

     <Directory /var/www/wordpress/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo apache2ctl configtest
sudo service apache2 restart

# Install phpmyadmin
apt-get install -y phpmyadmin
cd /etc/apache2/sites-available
sudo mv /etc/phpmyadmin/config.inc.php  config.inc_bak.php
sudo cp config.inc.php /etc/phpmyadmin/
sudo cp /etc/phpmyadmin/apache.conf phpmyadmin.conf
sudo a2ensite phpmyadmin.conf
sudo service apache2 restart

######## end of script #########
