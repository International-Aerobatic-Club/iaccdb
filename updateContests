#!/bin/sh
source ./railsEnv
LOG_FILE="/home/iaccdbor/log/update.log"
date >>$LOG_FILE
pwd 2>&1 1>>$LOG_FILE
rails runner cmd/updateContestDB.rb
bundle exec rake jobs:workoff
