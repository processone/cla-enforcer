# README.md 

## EC2 Instance Details

    Hosted in AWS, us-east-1. 
    t2.micro : Amazon Linux2 AMI (HVM), 1 vCPU, 1 GB RAM, 8GB SSD, x86_64

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

## Install PostgresSQL server 13


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
```

Import database dump: 

```
sudo -i -u postgres
psql
pg_dump -U postgres cla-enforcer < db.pgsql
```


