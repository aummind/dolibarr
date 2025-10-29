#!/bin/bash

# Setup script for Dolibarr development environment in Codespaces

echo "Setting up Dolibarr development environment..."

# Create necessary directories
sudo mkdir -p /workspace/htdocs/conf
sudo mkdir -p /var/www/documents
sudo chown -R www-data:www-data /var/www/documents
sudo chown -R www-data:www-data /workspace/htdocs/conf

# Create empty conf.php if it doesn't exist
if [ ! -f /workspace/htdocs/conf/conf.php ]; then
    echo "Creating empty conf.php for first-time setup..."
    sudo touch /workspace/htdocs/conf/conf.php
    sudo chmod 666 /workspace/htdocs/conf/conf.php
    sudo chown www-data:www-data /workspace/htdocs/conf/conf.php
fi

# Start Apache
sudo service apache2 start

echo ""
echo "=========================================="
echo "Dolibarr Development Environment Ready!"
echo "=========================================="
echo ""
echo "Web Interface: http://localhost"
echo "Database Host: mariadb"
echo "Database Name: dolibarr"
echo "Database User: dolibarr"
echo "Database Password: dolibarrpass"
echo "Root Password: rootpassfordev"
echo ""
echo "MailDev Interface: http://localhost:8081"
echo ""
echo "To complete installation, visit:"
echo "http://localhost/install/"
echo ""
echo "=========================================="
