$: << File.dirname(__FILE__)
require 'meta_project'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/rdoctask'
require 'jeweler'
load 'watchdogger.gemspec'

CLEAN.include("pkg", "lib/*.bundle", "html", "*.gem", ".config")

# Runs the test suite
Rake::TestTask.new do |task|
  task.test_files = FileList["test/*test.rb"]
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include("lib/**/*rb")
  rdoc.rdoc_files.include('LICENSE', 'CHANGES', 'README.rdoc', 'sample_config.yml')
  rdoc.main = "README.rdoc"
  rdoc.title = "Watchdogger Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
end

Jeweler::Tasks.new do |s|
  s.name = "watchdogger"
  s.summary = "Simple and flexible watchdog running on Ruby."
  s.email = "ghub@limitedcreativity.org"
  s.homepage = "http://averell23.github.com/watchdogger"
  s.description = "A small flexible watchdog system to monitor servers."
  s.authors = ["Daniel Hahn"]
  s.files = FileList["{lib,test,bin}/**/*"]
  s.extra_rdoc_files = ["README.rdoc", "CHANGES", "LICENSE", "sample_config.yml"]
  s.add_dependency('file-tail', '>= 1.0.3')
  s.add_dependency('averell23-assit', '>= 0.1.2')
  s.add_dependency('rmail', '>= 1.0.0')
  s.add_dependency('builder', '>= 2.1.2')
  s.add_dependency('optiflag', '>= 0.6.5')
end
