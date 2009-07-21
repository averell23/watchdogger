# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{watchdogger}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Hahn"]
  s.date = %q{2009-07-21}
  s.default_executable = %q{watchdogger}
  s.description = %q{A small flexible watchdog system to monitor servers.}
  s.email = %q{ghub@limitedcreativity.org}
  s.executables = ["watchdogger"]
  s.extra_rdoc_files = ["README.rdoc", "CHANGES", "LICENSE", "sample_config.yml"]
  s.files = ["lib/dog_log.rb", "lib/watchdogger.rb", "lib/watcher", "lib/watcher/base.rb", "lib/watcher/http_watcher.rb", "lib/watcher/log_watcher.rb", "lib/watcher.rb", "lib/watcher_action", "lib/watcher_action/htpost.rb", "lib/watcher_action/kill_process.rb", "lib/watcher_action/log_action.rb", "lib/watcher_action/meta_action.rb", "lib/watcher_action/send_mail.rb", "lib/watcher_action.rb", "lib/watcher_event.rb", "test/http_watcher_test.rb", "test/kill_process_test.rb", "test/log_watcher_test.rb", "test/meta_action_test.rb", "test/test_helper.rb", "test/watchdogger_test.rb", "bin/watchdogger", "README.rdoc", "CHANGES", "LICENSE", "sample_config.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://averell23.github.com/watchdogger}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Simple and flexible watchdog running on Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<file-tail>, [">= 1.0.3"])
      s.add_runtime_dependency(%q<averell23-assit>, [">= 0.1.2"])
      s.add_runtime_dependency(%q<rmail>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<optiflag>, [">= 0.6.5"])
      s.add_runtime_dependency(%q<tlsmail>, [">= 0.0.1"])
    else
      s.add_dependency(%q<file-tail>, [">= 1.0.3"])
      s.add_dependency(%q<averell23-assit>, [">= 0.1.2"])
      s.add_dependency(%q<rmail>, [">= 1.0.0"])
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<optiflag>, [">= 0.6.5"])
      s.add_dependency(%q<tlsmail>, [">= 0.0.1"])
    end
  else
    s.add_dependency(%q<file-tail>, [">= 1.0.3"])
    s.add_dependency(%q<averell23-assit>, [">= 0.1.2"])
    s.add_dependency(%q<rmail>, [">= 1.0.0"])
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<optiflag>, [">= 0.6.5"])
    s.add_dependency(%q<tlsmail>, [">= 0.0.1"])
  end
end
