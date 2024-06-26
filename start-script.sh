#!/bin/bash
source ~/.bash_profile
cd ~/cla-enforcer # Need to find Gemfile and .env
bundle exec dotenv /home/cla/cla-enforcer/bin/cla-enforcer > /home/cla/cla-enforcer/logs/app.log &
# You can "crontab -e" this with a dedicated "cla" user.

