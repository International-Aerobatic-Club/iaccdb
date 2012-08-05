IAC::RankComputer.instance.logger = Rails.logger
Delayed::Worker.logger = Rails.logger
require 'iac/mannyParse'
Manny::MannyParse.logger = Rails.logger

