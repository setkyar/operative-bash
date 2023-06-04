# operative-bash

Operative bash is collection of bash scripts that is pre-defined for your need.

```
OS - Ubuntu 22.04.* (LTS)
```

> You don't need to pay server management website . You just need a little bit of curiosity and bash script.

## Laravel

Setup ubuntu server for your Laravel application.

SSH to the server and git clone this repo. And `cd` into the repo and run the following.

```
wget https://raw.githubusercontent.com/setkyar/operative-bash/master/operative.sh
chmod +x ./operative.sh
sudo ./operative.sh
```

By running this, it will create a new user call `operative`.You can find the password from terminal output or you can look into at `output.txt`.

### Adding Laravel sites

```
wget https://raw.githubusercontent.com/setkyar/operative-bash/master/site.sh
chmod +x ./site.sh
./site.sh example.com "git@github.com:setkyar/operative.git" --laravel
```