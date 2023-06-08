#!/bin/bash

# Set default values
app_name=""
repository=""
flag=""

# Function to display script usage
usage() {
  echo "Usage: ./site.sh <domain_name> <repository> [--laravel|--node]"
}

echo "If you want to setup https, you have to point your domain to this server first."
echo -e "\n"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --laravel)
      flag="laravel"
      shift
      ;;
    --node)
      flag="node"
      shift
      ;;
    *)
      app_name="$1"
      repository="$2"
      shift
      ;;
  esac
  shift
done

# Validate required arguments
if [[ -z $app_name || -z $repository || -z $flag ]]; then
  usage
  exit 1
fi

# Perform actions based on the provided flag
case $flag in
  laravel)
    echo "Performing Laravel-related stuff for $app_name"

    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git clone $repository /var/www/$app_name

    # install composer
    cd /var/www/$app_name
    composer install

    cp .env.example .env
    php artisan key:generate

    # prepare nginx config file
    cd /etc/nginx/sites-enabled
    sudo wget -O $app_name https://raw.githubusercontent.com/setkyar/operative-bash/master/struts/laravel

    # replace app_name with $app_name
    sudo sed -i "s/example.com/$app_name/g" /etc/nginx/sites-enabled/$app_name

    # restart nginx
    sudo service nginx restart

    # laravel storage permission
    sudo chgrp -R www-data /var/www/$app_name/storage /var/www/$app_name/bootstrap/cache
    sudo chmod -R ug+rwx /var/www/$app_name/storage /var/www/$app_name/bootstrap/cache

    # Ask the user if they want to add Certbot
    read -p "Do you want to add Certbot? (y/n): " add_certbot

    if [[ $add_certbot =~ ^[Yy]$ ]]; then
        # Split the domain into parts using dot as the delimiter
        IFS='.' read -ra domain_parts <<< "$app_name"

        # Check if the domain has more than one part
        if (( ${#domain_parts[@]} > 2 )); then
            echo "The domain $app_name is a subdomain."
            sudo certbot --nginx -d "$app_name"
        else
            sudo certbot --nginx -d "$app_name" -d "www.$app_name"
        fi
    fi


    echo "Laravel site $app_name has been set up!"
    ;;
  node)
    echo "Performing Node-related stuff for $app_name"
    # Node-specific commands

    echo "Performing Laravel-related stuff for $app_name"

    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git clone $repository /var/www/$app_name

    # install npm
    cd /var/www/$app_name
    npm install

    # start with pm2
    if pm2 id $app_name &> /dev/null; then
      pm2 delete $app_name
    fi
    pm2 start npm --name "$app_name" -- start

    # prepare nginx config file
    cd /etc/nginx/sites-enabled
    sudo wget -O $app_name https://raw.githubusercontent.com/setkyar/operative-bash/master/struts/proxy-pass

    # replace app_name with $app_name
    sudo sed -i "s/example.com/$app_name/g" /etc/nginx/sites-enabled/$app_name

    # ask user to enter port number
    echo "Enter port number for $app_name"
    read port_number

    # replace port_number with $port_number
    sudo sed -i "s/3000/$port_number/g" /etc/nginx/sites-enabled/$app_name

    # restart nginx
    sudo service nginx restart

    # certbot
    # Split the domain into parts using dot as the delimiter
    IFS='.' read -ra domain_parts <<< $app_name

    # Check if the domain has more than one part
    if [ "${#domain_parts[@]}" -gt 2 ]; then
      echo "The domain $domain is a subdomain."
      sudo certbot --nginx -d $app_name
    else
      sudo certbot --nginx -d $app_name -d www.$app_name
    fi
    ;;
  *)
    echo "Invalid flag: $flag"
    usage
    exit 1
    ;;
esac