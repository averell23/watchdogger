require 'rubygems'
require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib', 'watchdogger')

DogLog.setup('tmp.log', Logger::DEBUG)