# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: nucleon 0.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "nucleon"
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Adrian Webb"]
  s.date = "2014-11-27"
  s.description = "\nA framework that provides a simple foundation for building Ruby applications that are:\n\n* Highly configurable (with both distributed and persistent configurations)\n* Extremely pluggable and extendable\n* Easily parallel\n\nNote: This framework is still very early in development!\n"
  s.email = "adrian.webb@coralnexus.com"
  s.executables = ["nucleon"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
    ".gitmodules",
    "ARCHITECTURE.rdoc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "TODO.rdoc",
    "VERSION",
    "bin/nucleon",
    "lib/core/codes.rb",
    "lib/core/config.rb",
    "lib/core/config/collection.rb",
    "lib/core/config/options.rb",
    "lib/core/core.rb",
    "lib/core/environment.rb",
    "lib/core/errors.rb",
    "lib/core/facade.rb",
    "lib/core/gems.rb",
    "lib/core/manager.rb",
    "lib/core/mixin/action/commit.rb",
    "lib/core/mixin/action/project.rb",
    "lib/core/mixin/action/push.rb",
    "lib/core/mixin/action/registration.rb",
    "lib/core/mixin/colors.rb",
    "lib/core/mixin/config/collection.rb",
    "lib/core/mixin/config/options.rb",
    "lib/core/mixin/macro/object_interface.rb",
    "lib/core/mixin/macro/plugin_interface.rb",
    "lib/core/mixin/settings.rb",
    "lib/core/mixin/sub_config.rb",
    "lib/core/mod/hash.rb",
    "lib/core/plugin/action.rb",
    "lib/core/plugin/base.rb",
    "lib/core/plugin/command.rb",
    "lib/core/plugin/event.rb",
    "lib/core/plugin/extension.rb",
    "lib/core/plugin/project.rb",
    "lib/core/plugin/template.rb",
    "lib/core/plugin/translator.rb",
    "lib/core/util/cache.rb",
    "lib/core/util/cli.rb",
    "lib/core/util/console.rb",
    "lib/core/util/data.rb",
    "lib/core/util/disk.rb",
    "lib/core/util/git.rb",
    "lib/core/util/liquid.rb",
    "lib/core/util/logger.rb",
    "lib/core/util/package.rb",
    "lib/core/util/shell.rb",
    "lib/core/util/ssh.rb",
    "lib/nucleon.rb",
    "lib/nucleon/action/extract.rb",
    "lib/nucleon/action/project/add.rb",
    "lib/nucleon/action/project/create.rb",
    "lib/nucleon/action/project/remove.rb",
    "lib/nucleon/action/project/save.rb",
    "lib/nucleon/action/project/update.rb",
    "lib/nucleon/command/bash.rb",
    "lib/nucleon/event/regex.rb",
    "lib/nucleon/extension/project.rb",
    "lib/nucleon/project/git.rb",
    "lib/nucleon/project/github.rb",
    "lib/nucleon/template/JSON.rb",
    "lib/nucleon/template/YAML.rb",
    "lib/nucleon/template/wrapper.rb",
    "lib/nucleon/translator/JSON.rb",
    "lib/nucleon/translator/YAML.rb",
    "lib/nucleon_base.rb",
    "locales/en.yml",
    "nucleon.gemspec",
    "spec/core/codes_spec.rb",
    "spec/core/config_spec.rb",
    "spec/core/core_spec.rb",
    "spec/core/environment_spec.rb",
    "spec/core/util/console_spec.rb",
    "spec/nucleon/test.rb",
    "spec/nucleon/test/first.rb",
    "spec/nucleon/test/second.rb",
    "spec/nucleon_codes.rb",
    "spec/nucleon_config.rb",
    "spec/nucleon_plugin.rb",
    "spec/nucleon_test.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/coralnexus/nucleon"
  s.licenses = ["Apache License, Version 2.0"]
  s.rdoc_options = ["--title", "Nucleon", "--main", "README.rdoc", "--line-numbers"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.1")
  s.rubyforge_project = "nucleon"
  s.rubygems_version = "2.2.2"
  s.summary = "Easy and minimal framework for building extensible distributed applications"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<log4r>, ["~> 1.1"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.6"])
      s.add_runtime_dependency(%q<netrc>, ["~> 0.7"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.6"])
      s.add_runtime_dependency(%q<erubis>, ["~> 2.7"])
      s.add_runtime_dependency(%q<deep_merge>, ["~> 1.0"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.7"])
      s.add_runtime_dependency(%q<sshkey>, ["~> 1.6"])
      s.add_runtime_dependency(%q<childprocess>, ["~> 0.5"])
      s.add_runtime_dependency(%q<celluloid>, ["~> 0.15"])
      s.add_runtime_dependency(%q<rugged>, ["~> 0.19"])
      s.add_runtime_dependency(%q<octokit>, ["~> 2.7"])
      s.add_development_dependency(%q<bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.10"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<yard>, ["~> 0.8"])
      s.add_development_dependency(%q<pry>, ["~> 0.9"])
      s.add_development_dependency(%q<pry-stack_explorer>, ["~> 0.4"])
      s.add_development_dependency(%q<pry-byebug>, ["~> 1.3"])
    else
      s.add_dependency(%q<log4r>, ["~> 1.1"])
      s.add_dependency(%q<i18n>, ["~> 0.6"])
      s.add_dependency(%q<netrc>, ["~> 0.7"])
      s.add_dependency(%q<highline>, ["~> 1.6"])
      s.add_dependency(%q<erubis>, ["~> 2.7"])
      s.add_dependency(%q<deep_merge>, ["~> 1.0"])
      s.add_dependency(%q<multi_json>, ["~> 1.7"])
      s.add_dependency(%q<sshkey>, ["~> 1.6"])
      s.add_dependency(%q<childprocess>, ["~> 0.5"])
      s.add_dependency(%q<celluloid>, ["~> 0.15"])
      s.add_dependency(%q<rugged>, ["~> 0.19"])
      s.add_dependency(%q<octokit>, ["~> 2.7"])
      s.add_dependency(%q<bundler>, ["~> 1.2"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 2.10"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<yard>, ["~> 0.8"])
      s.add_dependency(%q<pry>, ["~> 0.9"])
      s.add_dependency(%q<pry-stack_explorer>, ["~> 0.4"])
      s.add_dependency(%q<pry-byebug>, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<log4r>, ["~> 1.1"])
    s.add_dependency(%q<i18n>, ["~> 0.6"])
    s.add_dependency(%q<netrc>, ["~> 0.7"])
    s.add_dependency(%q<highline>, ["~> 1.6"])
    s.add_dependency(%q<erubis>, ["~> 2.7"])
    s.add_dependency(%q<deep_merge>, ["~> 1.0"])
    s.add_dependency(%q<multi_json>, ["~> 1.7"])
    s.add_dependency(%q<sshkey>, ["~> 1.6"])
    s.add_dependency(%q<childprocess>, ["~> 0.5"])
    s.add_dependency(%q<celluloid>, ["~> 0.15"])
    s.add_dependency(%q<rugged>, ["~> 0.19"])
    s.add_dependency(%q<octokit>, ["~> 2.7"])
    s.add_dependency(%q<bundler>, ["~> 1.2"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 2.10"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<yard>, ["~> 0.8"])
    s.add_dependency(%q<pry>, ["~> 0.9"])
    s.add_dependency(%q<pry-stack_explorer>, ["~> 0.4"])
    s.add_dependency(%q<pry-byebug>, ["~> 1.3"])
  end
end

