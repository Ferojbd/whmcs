#!/bin/bash

# Update system packages
sudo dnf update -y

# Install Apache web server
sudo dnf install httpd -y

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Install PHP 8.1 and required extensions
sudo dnf module enable php:remi-8.1 -y
sudo dnf install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-iconv -y

# Check PHP version and modules
php -v
php -m | grep ioncube  # Ensure ionCube loader is installed

# Install ionCube Loader (if not installed already)
# Follow installation instructions from ionCube's website: https://www.ioncube.com/loaders.php

# Download and extract WHMCS
sudo dnf install wget unzip -y
wget https://releases.whmcs.com/v2/pkgs/whmcs-8.10.1-release.1.zip
unzip whmcs-8.10.1-release.1.zip -d /home/api/my.itpolly.com

# Set permissions for WHMCS
sudo chown -R apache:apache /home/api/my.itpolly.com
sudo chmod -R 755 /home/api/my.itpolly.com

# Configure Apache virtual host for my.itpolly.com
sudo tee /etc/httpd/conf.d/my.itpolly.com.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@my.itpolly.com
    ServerName my.itpolly.com
    DocumentRoot /home/api/my.itpolly.com

    <Directory /home/api/my.itpolly.com>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/my.itpolly.com-error.log
    CustomLog /var/log/httpd/my.itpolly.com-access.log combined
</VirtualHost>
EOF

# Restart Apache to apply changes
sudo systemctl restart httpd

# Install Certbot for Let's Encrypt (optional)
sudo dnf install certbot python3-certbot-apache -y

# Obtain SSL certificate for my.itpolly.com (if Certbot is installed)
sudo certbot --apache -d my.itpolly.com

# Cleanup
rm -rf whmcs-8.10.1-release.1.zip

echo "Installation completed successfully."
