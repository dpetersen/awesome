#!/bin/zsh
if [ -s ~/.rvm/scripts/rvm ] ; then source ~/.rvm/scripts/rvm ; fi
rvm use 1.8.7
ruby /home/dpetersen/.config/awesome/scripts/weather.rb 54169
