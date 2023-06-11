#!/bin/bash

# check if user provided public key
if [[ -z $1 ]]; then
  echo "Please provide your public key as an argument."
  exit 1
fi

public_key=$1

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
echo "Installing necessary packages..."

echo "Installing nginx..."
sudo apt install nginx -y

echo "Installing certbot..."
sudo apt install certbot python3-certbot-nginx -y

echo "Installing mysql..."
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 12)

sudo apt install mysql-server -y
sudo service mysql start
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"

echo "MySQL root password: $MYSQL_ROOT_PASSWORD"

echo "Setting up user operative user..."

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

# Add operative user to www-data group
sudo usermod -a -G www-data operative
sudo chown -R www-data:www-data /var/www
sudo chown -R operative:www-data /var/www

# clean up default nginx files
sudo rm -rf /var/www/html/
sudo rm /etc/nginx/sites-enabled/default

echo "MySQL root password: $MYSQL_ROOT_PASSWORD" >> output.txt

echo "Installing composer..."
sudo apt install composer -y

echo "Installing php..."
sudo apt install php php-fpm php-mbstring php-xml php-bcmath php-curl -y

# Switch to the operative user
sudo su - operative -c "

cd /home/operative/

# Install nvm
echo 'Installing nvm...'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source /home/operative/.bashrc

# Load nvm environment
source /home/operative/.nvm/nvm.sh

nvm install --lts
nvm alias default node

# Install pm2
echo 'Installing pm2...'
npm install pm2 -g

# Generate ssh key for the operative user
echo 'Generating ssh key for the operative user...'
ssh-keygen -t rsa -b 4096 -f /home/operative/.ssh/id_rsa -q -N ''

# Create authorized_keys file
touch /home/operative/.ssh/authorized_keys
chmod 600 /home/operative/.ssh/authorized_keys

printf '%s' '$public_key' >> /home/operative/.ssh/authorized_keys
"

echo "You can now login to the operative user with the following command:"
echo "ssh operative@$(curl -s ifconfig.me)"

echo "You can get the MySQL root password and operative user's password from the output.txt file"