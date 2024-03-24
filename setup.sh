#!/bin/bash

# Function to install LAMP stack with Nginx and Node.js
install_lamp_stack() {
    # Step 1: Installing Nginx
    sudo apt update
    sudo apt install nginx

    # Step 2: Installing MySQL
    sudo apt install mysql-server

    # Check MySQL service status
    sudo systemctl status mysql

    # Prompt user for MySQL username and password
    read -p "Enter MySQL username: " mysql_user
    read -sp "Enter MySQL password: " mysql_password
    echo

    # Set MySQL root password
    sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysql_password';
FLUSH PRIVILEGES;
exit;
EOF

    # Verify MySQL socket path
    mysql_socket_path=$(sudo grep -oP 'socket\s*=\s*\K\S+' /etc/mysql/mysql.conf.d/mysqld.cnf)
    echo "MySQL socket path: $mysql_socket_path"

    # Step 2: Installing phpMyAdmin
    sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
    sudo phpenmod mbstring
    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    # Step 3: Installing PHP and Configuring Nginx
    sudo apt install php-fpm php-mysql php-xml

    # Composer Installation
    sudo apt install php-cli unzip
    cd ~
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
    HASH=$(curl -sS https://composer.github.io/installer.sig)
    echo $HASH
    php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

    # Step 4: Installing Node.js using NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc
    nvm list-remote
    echo "Enter the Node.js version you want to install (e.g., v16.14.0):"
    read node_version
    nvm install $node_version

    # Install npm and PM2
    sudo apt-get install npm
    sudo npm i -g pm2

    echo "Setup complete."
}

# Function to remove LAMP stack with Nginx and Node.js
remove_lamp_stack() {
    # Step 1: Remove Node.js and PM2
    sudo npm uninstall -g pm2
    nvm deactivate
    nvm uninstall --lts
    nvm uninstall --latest-npm

    # Step 2: Remove Composer
    sudo rm -rf /usr/local/bin/composer

    # Step 3: Remove PHP and PHP extensions
    sudo apt purge php-fpm php-mysql php-xml php-cli php-mbstring php-zip php-gd php-json php-curl
    sudo apt autoremove
    sudo apt autoclean

    # Step 4: Remove phpMyAdmin
    sudo rm -rf /var/www/html/phpmyadmin
    sudo apt purge phpmyadmin

    # Step 5: Remove MySQL
    sudo apt purge mysql-server
    sudo apt autoremove
    sudo apt autoclean

    # Step 6: Remove Nginx
    sudo apt purge nginx
    sudo apt autoremove
    sudo apt autoclean

    echo "Cleanup complete."
}

# Main script
echo "Choose an option:"
echo "1. Install LAMP stack with Nginx and Node.js"
echo "2. Remove LAMP stack with Nginx and Node.js"

read -p "Enter your choice (1 or 2): " choice

case $choice in
    1) install_lamp_stack ;;
    2) remove_lamp_stack ;;
    *) echo "Invalid choice";;
esac
