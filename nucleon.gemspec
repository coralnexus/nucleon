# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "nucleon"
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adrian Webb"]
  s.date = "2014-03-16"
  s.description = "\nA framework that provides a simple foundation for building Ruby applications that are:\n\n* Highly configurable (with both distributed and persistent configurations)\n* Extremely pluggable and extendable\n* Easily parallel\n\nNote: This framework is still very early in development!\n"
  s.email = "adrian.webb@coralnexus.com"
  s.executables = ["nucleon"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/nucleon",
    "lib/core/codes.rb",
    "lib/core/config.rb",
    "lib/core/config/collection.rb",
    "lib/core/config/options.rb",
    "lib/core/core.rb",
    "lib/core/errors.rb",
    "lib/core/facade.rb",
    "lib/core/gems.rb",
    "lib/core/manager.rb",
    "lib/core/mixin/action/commit.rb",
    "lib/core/mixin/action/project.rb",
    "lib/core/mixin/action/push.rb",
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
    "lib/nucleon/action/add.rb",
    "lib/nucleon/action/create.rb",
    "lib/nucleon/action/extract.rb",
    "lib/nucleon/action/remove.rb",
    "lib/nucleon/action/save.rb",
    "lib/nucleon/action/update.rb",
    "lib/nucleon/command/bash.rb",
    "lib/nucleon/event/regex.rb",
    "lib/nucleon/project/git.rb",
    "lib/nucleon/project/github.rb",
    "lib/nucleon/template/json.rb",
    "lib/nucleon/template/wrapper.rb",
    "lib/nucleon/template/yaml.rb",
    "lib/nucleon/translator/json.rb",
    "lib/nucleon/translator/yaml.rb",
    "lib/nucleon_base.rb",
    "locales/en.yml",
    "nucleon.gemspec",
    "spec/coral_mock_input.rb",
    "spec/coral_test_kernel.rb",
    "spec/core/util/console_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/coralnexus/nucleon"
  s.licenses = ["GPLv3"]
  s.rdoc_options = ["--title", "Nucleon", "--main", "README.rdoc", "--line-numbers"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.1")
  s.rubyforge_project = "nucleon"
  s.rubygems_version = "1.8.11"
  s.summary = "Framework that provides a simple foundation for building distributively configured, extremely pluggable and extendable, and easily parallel Ruby applications"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<log4r>, ["~> 1.1"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.6"])
      s.add_runtime_dependency(%q<netrc>, ["~> 0.7"])
      s.add_runtime_dependency(%q<deep_merge>, ["~> 1.0"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.7"])
      s.add_runtime_dependency(%q<sshkey>, ["~> 1.6"])
      s.add_runtime_dependency(%q<childprocess>, ["~> 0.5.0"])
      s.add_runtime_dependency(%q<celluloid>, ["~> 0.15"])
      s.add_runtime_dependency(%q<grit>, ["~> 2.5"])
      s.add_runtime_dependency(%q<octokit>, ["~> 2.7"])
      s.add_development_dependency(%q<bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.10"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<yard>, ["~> 0.8"])
    else
      s.add_dependency(%q<log4r>, ["~> 1.1"])
      s.add_dependency(%q<i18n>, ["~> 0.6"])
      s.add_dependency(%q<netrc>, ["~> 0.7"])
      s.add_dependency(%q<deep_merge>, ["~> 1.0"])
      s.add_dependency(%q<multi_json>, ["~> 1.7"])
      s.add_dependency(%q<sshkey>, ["~> 1.6"])
      s.add_dependency(%q<childprocess>, ["~> 0.5.0"])
      s.add_dependency(%q<celluloid>, ["~> 0.15"])
      s.add_dependency(%q<grit>, ["~> 2.5"])
      s.add_dependency(%q<octokit>, ["~> 2.7"])
      s.add_dependency(%q<bundler>, ["~> 1.2"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 2.10"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<yard>, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<log4r>, ["~> 1.1"])
    s.add_dependency(%q<i18n>, ["~> 0.6"])
    s.add_dependency(%q<netrc>, ["~> 0.7"])
    s.add_dependency(%q<deep_merge>, ["~> 1.0"])
    s.add_dependency(%q<multi_json>, ["~> 1.7"])
    s.add_dependency(%q<sshkey>, ["~> 1.6"])
    s.add_dependency(%q<childprocess>, ["~> 0.5.0"])
    s.add_dependency(%q<celluloid>, ["~> 0.15"])
    s.add_dependency(%q<grit>, ["~> 2.5"])
    s.add_dependency(%q<octokit>, ["~> 2.7"])
    s.add_dependency(%q<bundler>, ["~> 1.2"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 2.10"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<yard>, ["~> 0.8"])
  end
end

