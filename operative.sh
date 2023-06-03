#!/bin/bash

echo "Updating local package index..."
sudo apt update -y

echo "Upgrading local packages..."
sudo apt upgrade -y

# setting up 1GB swap space
echo "Setting up swap space..."
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab


# Install necessary packages

echo "Setting up user operative..."

# Generate a random password
password=$(openssl rand -base64 12)

# Create the user with sudo access
sudo useradd -m -G sudo -s /bin/bash operative && echo "operative:$password" | sudo chpasswd

# Set the generated password for the user
echo -e "$password\n$password" | sudo passwd operative

# Print the generated password
echo "User 'operative' has been created with sudo access."
echo "The generated password for 'operative' is: $password"
echo "The generated password for 'operative' is: $password" > output.txt

echo "Installing nginx..."
sudo apt install nginx -y

echo "Installing mysql..."

MYSQL_ROOT_PASSWORD=$(openssl rand -base64 12)

sudo apt install mysql-server -y
sudo service mysql start
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"

echo "MySQL root password: $mysqlPassword"
echo "MySQL root password: $mysqlPassword" >> output.txt

echo "Installing composer..."
sudo apt install composer -y

echo "Installing php..."
sudo apt install php php-mbstring php-xml php-bcmath php-curl -y

# Switch to the operative user
sudo su operative

cd /home/operative/

# Generate ssh key for the operative user
echo "Generating ssh key for the operative user..."
ssh-keygen -t rsa -b 4096 -f /home/operative/.ssh/id_rsa -q -N ""

sudo su

# Create the .ssh directory and authorized_keys file
mkdir /home/operative/.ssh
touch /home/operative/.ssh/authorized_keys