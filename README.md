# README.md 

## EC2 Instance Details

- Hosted in AWS, us-east-1. 
- t2.micro : Amazon Linux2 AMI (HVM), 1 vCPU, 1 GB RAM, 8GB SSD, x86_64

## Setup 

### Create a dedicated user for the ruby app

```
sudo useradd cla
```

### Install system packages

```
sudo amazon-linux-extras install ruby3.0
sudo yum install git gcc ruby-devel
```

### Install other packages for the app

    
See (wkhtmltopdf : to generate PDF from HTML)
- https://wkhtmltopdf.org/downloads.html
- 

```
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.amazonlinux2.x86_64.rpm
sudo yum install wkhtmltox-0.12.6-1.amazonlinux2.x86_64.rpm
```

### Clone this repository 

```
cd /home/cla
git clone https://github.com/processone/cla-enforcer.git
```

### Install gems 

```
gem install bundler:1.16.6
```

### Run a bundle install/update

To ensure things are set up properly and you don't lack any system packages / headers / compilers

```
bundle install
bundle update
```

If you have issues with installing `pg`, you can do : 

```
bundle config build.pg --with-pg-config=/usr/pgsql-13/bin/pg_config
bundle install 
```

### Install PostgresSQL server 13


Execute this as one command: 

```
sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg13]
name=PostgreSQL 13 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF
```

Then: 

```
yum update
sudo yum install postgresql13 postgresql13-server
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl start postgresql-13
sudo systemctl enable postgresql-13
sudo systemctl status postgresql-13
```

```
sudo -i
sudo -i -u postgres
psql
> CREATE DATABASE "cla-enforcer";
> CREATE ROLE cla LOGIN;
```

Import database dump: 

```
sudo -i -u postgres
pg_dump -U postgres cla-enforcer < db.pgsql
```

### Populate the .env file

You can use the .env.sample as an example. 
It has to be in the root of the project.

## Run the app

`bundle exec dotenv bin/cla-enforcer`

## Install Caddy web server


### Install Go (1.18+) and Caddy: 

```
yum install golang
git clone "https://github.com/caddyserver/caddy.git"
cd caddy/cmd/caddy
go build
mv caddy /usr/local/bin

```

### Create user and group caddy

```
sudo groupadd --system caddy
sudo useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy
```

### Create a unit file containing: 

Location : `/etc/systemd/system/caddy.service`

```
# caddy.service
#
# For using Caddy with a config file.
#
# Make sure the ExecStart and ExecReload commands are correct
# for your installation.
#
# See https://caddyserver.com/docs/install for instructions.
#
# WARNING: This service does not use the --resume flag, so if you
# use the API to make changes, they will be overwritten by the
# Caddyfile next time the service is restarted. If you intend to
# use Caddy's API to configure it, add the --resume flag to the
# `caddy run` command or use the caddy-api.service file instead.

[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateDevices=yes
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

### Create a Caddyfile

Location : `/etc/caddy/Caddyfile`

```
domain.net {
        reverse_proxy localhost:PORT
}

```

### Enable service and start it

```
sudo systemctl daemon-reload
sudo systemctl enable --now caddy
```


# Links

- https://github.com/processone/cla-enforcer
- https://caddyserver.com/docs/build
- https://caddyserver.com/docs/running#manual-installation
