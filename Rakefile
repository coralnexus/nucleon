# encoding: utf-8

require 'rubygems'
require 'rake'
require 'bundler'
require 'jeweler'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'yard'

require './lib/coral_core.rb'

#-------------------------------------------------------------------------------
# Dependencies

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

#-------------------------------------------------------------------------------
# Gem specification

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name                  = "coral_core"
  gem.homepage              = "http://github.com/coralnexus/ruby-coral_core"
  gem.rubyforge_project     = 'coral_core'
  gem.license               = "GPLv3"
  gem.email                 = "adrian.webb@coraltech.net"
  gem.authors               = ["Adrian Webb"]
  gem.summary               = %Q{Provides core data elements and utilities used in other Coral gems}
  gem.description           = File.read('README.rdoc')  
  gem.required_ruby_version = '>= 1.8.1'
  gem.has_rdoc              = true
  gem.rdoc_options << '--title' << 'Coral Core library' <<
                      '--main' << 'README.rdoc' <<
                      '--line-numbers'
                      
  gem.files.include Dir.glob('bootstrap/**/*') 
  
  # Dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

#-------------------------------------------------------------------------------
# Testing

RSpec::Core::RakeTask.new(:spec, :tag) do |spec, task_args|
  options = []
  options << "--tag #{task_args[:tag]}" if task_args.is_a?(Array) && ! task_args[:tag].to_s.empty?  
  spec.rspec_opts = options.join(' ')
end

task :default => :spec

#-------------------------------------------------------------------------------
# Documentation

version   = Coral::VERSION
doc_title = "coral_core #{version}"

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = doc_title
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

#---

YARD::Rake::YardocTask.new do |ydoc|
  ydoc.files   = [ 'README*', 'lib/**/*.rb' ]
  ydoc.options = [ "--output-dir yardoc", "--title '#{doc_title}'" ]
end
