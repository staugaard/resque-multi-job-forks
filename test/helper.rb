require 'rubygems'
require 'test/unit'

require 'bundler'
Bundler.setup
Bundler.require

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
$TESTING = true

require 'resque-multi-job-forks'
