# Operative-Bash

Operative Bash is a collection of pre-defined bash scripts tailored to your needs.

```
OS - Ubuntu 22.04.* (LTS)
```

> You don't need to pay for a server management website. You just need a little bit of curiosity and a bash script.

You can check out the video guide [here](https://www.loom.com/share/53ebb1d8945148f7be8aab4b8046ef2f).

## Setting up the Operative user and installing necessary software

SSH to the server and clone this repository. Then, navigate to the repository directory and run the following commands:

```
wget https://raw.githubusercontent.com/setkyar/operative-bash/master/operative.sh
chmod +x ./operative.sh
sudo ./operative.sh {{ YOUR_LOCAL_SSH_PUBLIC_KEY }}
```

By running this, it will create a new user called `operative`. You can find the password in the terminal output or you can look for it in `output.txt`.

### Adding Laravel sites

You can easily add a Laravel site by following these steps:

```
wget https://raw.githubusercontent.com/setkyar/operative-bash/master/site.sh
chmod +x ./site.sh
./site.sh example.com "git@github.com:setkyar/operative-laravel-simple.git" --laravel
```

### Adding NodeJS sites

You can easily add NodeJS sites by following these steps. It will prompt you to enter the port number on which your application is running, and then it will automatically set up the proxy pass for you.

```
wget https://raw.githubusercontent.com/setkyar/operative-bash/master/site.sh
chmod +x ./site.sh
./site.sh example.com "git@github.com:setkyar/operative-express-simple.git" --node
```