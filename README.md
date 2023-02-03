# Hello

# EC2

    Hosted in AWS, us-east-1. 
    t2.micro : Amazon Linux2 AMI (HVM), 1 vCPU, 1 GB RAM, 8GB SSD, x86_64

# Setup 

## Create a dedicated user for the ruby app

```
sudo useradd cla
```

## Install system packages

See : 
    - https://wkhtmltopdf.org/downloads.html
    - 
```
sudo amazon-linux-extras install ruby3.0
sudo yum install git 
```

## Install the needed packages for the app

```
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.amazonlinux2.x86_64.rpm
sudo yum install wkhtmltox-0.12.6-1.amazonlinux2.x86_64.rpm
```

## Clone this repository 

```
cd /home/cla
git clone https://github.com/processone/cla-enforcer.git
```
