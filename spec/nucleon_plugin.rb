
#
# Require test plugin type
#
require File.join(File.dirname(__FILE__), 'nucleon', 'test.rb')


RSpec.shared_context "nucleon_plugin" do

  include_context "nucleon_test"

  #*****************************************************************************
  # Plugin environment data

  let(:plugin_environment_empty) do {
      :plugin_types => {},
      :load_info    => {},
      :active_info  => {}
    }
  end


  let(:plugin_registry) do {
      :nucleon => {
        :extension  => nil,
        :action     => :project_update,
        :project    => :git,
        :command    => :bash,
        :event      => :regex,
        :template   => :json,
        :translator => :json
      }
    }
  end

  let(:plugin_base_path) do
    File.expand_path('..', File.dirname(__FILE__))
  end

  let(:plugin_loaded_plugins) do
    plugin_directory         = File.join(plugin_base_path, 'lib', 'nucleon')
    project_directory        = File.join(plugin_directory, 'project')
    event_directory          = File.join(plugin_directory, 'event')
    extension_directory      = File.join(plugin_directory, 'extension')
    command_directory        = File.join(plugin_directory, 'command')
    translator_directory     = File.join(plugin_directory, 'translator')
    action_directory         = File.join(plugin_directory, 'action')
    action_project_directory = File.join(action_directory, 'project')
    template_directory       = File.join(plugin_directory, 'template')

    {
      :nucleon => {
        :project => {
          :github => {
            :namespace        => :nucleon,
            :type             => :project,
            :base_path        => project_directory,
            :file             => File.join(project_directory, 'github.rb'),
            :provider         => :github,
            :directory        => project_directory,
            :class_components => [ "Nucleon", "Project", "Github" ]
          },
          :git => {
            :namespace        => :nucleon,
            :type             => :project,
            :base_path        => project_directory,
            :file             => File.join(project_directory, 'git.rb'),
            :provider         => :git,
            :directory        => project_directory,
            :class_components => [ "Nucleon", "Project", "Git" ]
          }
        },
        :event => {
          :regex => {
            :namespace        => :nucleon,
            :type             => :event,
            :base_path        => event_directory,
            :file             => File.join(event_directory, 'regex.rb'),
            :provider         => :regex,
            :directory        => event_directory,
            :class_components => ["Nucleon", "Event", "Regex"]
          }
        },
        :extension => {
          :project => {
            :namespace        => :nucleon,
            :type             => :extension,
            :base_path        => extension_directory,
            :file             => File.join(extension_directory, 'project.rb'),
            :provider         => :project,
            :directory        => extension_directory,
            :class_components => ["Nucleon", "Extension", "Project"]
          }
        },
        :command => {
          :bash => {
            :namespace        => :nucleon,
            :type             => :command,
            :base_path        => command_directory,
            :file             => File.join(command_directory, 'bash.rb'),
            :provider         => :bash,
            :directory        => command_directory,
            :class_components => ["Nucleon", "Command", "Bash"]
          }
        },
        :translator => {
          :json => {
            :namespace        => :nucleon,
            :type             => :translator,
            :base_path        => translator_directory,
            :file             => File.join(translator_directory, 'JSON.rb'),
            :provider         => :json,
            :directory        => translator_directory,
            :class_components => [ "Nucleon", "Translator", "JSON" ]
          },
          :yaml => {
            :namespace        => :nucleon,
            :type             => :translator,
            :base_path        => translator_directory,
            :file             => File.join(translator_directory, 'YAML.rb'),
            :provider         => :yaml,
            :directory        => translator_directory,
            :class_components => [ "Nucleon", "Translator", "YAML" ]
          }
        },
        :action => {
          :project_update => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'update.rb'),
            :provider         => :project_update,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Update" ]
          },
          :project_create => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'create.rb'),
            :provider         => :project_create,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Create" ]
          },
          :project_save => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'save.rb'),
            :provider         => :project_save,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Save" ]
          },
          :project_remove => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'remove.rb'),
            :provider         => :project_remove,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Remove" ]
          },
          :project_add => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'add.rb'),
            :provider         => :project_add,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Add" ]
          },
          :extract => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_directory, 'extract.rb'),
            :provider         => :extract,
            :directory        => action_directory,
            :class_components => [ "Nucleon", "Action", "Extract" ]
          }
        },
        :template => {
          :json => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => File.join(template_directory, 'JSON.rb'),
            :provider         => :json,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "JSON" ]
          },
          :yaml => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => File.join(template_directory, 'YAML.rb'),
            :provider         => :yaml,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "YAML" ]
          },
          :wrapper => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => File.join(template_directory, 'wrapper.rb'),
            :provider         => :wrapper,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "Wrapper" ]
          }
        }
      }
    }
  end

  def plugin_define_plugins(environment, plugin_type, provider_map, &code)
    plugin_type = plugin_type.to_sym
    plugin_path = File.join(plugin_base_path, 'lib', 'nucleon', plugin_type.to_s)

    provider_map.each do |provider, file_name|
      provider = provider.to_sym

      if file_name.is_a?(Array)
        file_name = File.join(*file_name)
      end

      environment.define_plugin(:nucleon, plugin_type, plugin_path, File.join(plugin_path, "#{file_name}.rb"))
      code.call(plugin_type, provider) if code
    end
  end


  let(:plugin_autoload_plugins) do
    loaded_plugins = Nucleon::Util::Data.clone(plugin_loaded_plugins)

    # Simulate autoloading of defined plugins

    require loaded_plugins[:nucleon][:project][:github][:file]
    loaded_plugins[:nucleon][:project][:github][:class] = Nucleon::Project::Github

    require loaded_plugins[:nucleon][:project][:git][:file]
    loaded_plugins[:nucleon][:project][:git][:class] = Nucleon::Project::Git

    require loaded_plugins[:nucleon][:event][:regex][:file]
    loaded_plugins[:nucleon][:event][:regex][:class] = Nucleon::Event::Regex

    require loaded_plugins[:nucleon][:extension][:project][:file]
    loaded_plugins[:nucleon][:extension][:project][:class] = Nucleon::Extension::Project

    require loaded_plugins[:nucleon][:command][:bash][:file]
    loaded_plugins[:nucleon][:command][:bash][:class] = Nucleon::Command::Bash

    require loaded_plugins[:nucleon][:translator][:json][:file]
    loaded_plugins[:nucleon][:translator][:json][:class] = Nucleon::Translator::JSON

    require loaded_plugins[:nucleon][:translator][:yaml][:file]
    loaded_plugins[:nucleon][:translator][:yaml][:class] = Nucleon::Translator::YAML

    require loaded_plugins[:nucleon][:action][:project_update][:file]
    loaded_plugins[:nucleon][:action][:project_update][:class] = Nucleon::Action::Project::Update

    require loaded_plugins[:nucleon][:action][:project_create][:file]
    loaded_plugins[:nucleon][:action][:project_create][:class] = Nucleon::Action::Project::Create

    require loaded_plugins[:nucleon][:action][:project_save][:file]
    loaded_plugins[:nucleon][:action][:project_save][:class] = Nucleon::Action::Project::Save

    require loaded_plugins[:nucleon][:action][:project_remove][:file]
    loaded_plugins[:nucleon][:action][:project_remove][:class] = Nucleon::Action::Project::Remove

    require loaded_plugins[:nucleon][:action][:project_add][:file]
    loaded_plugins[:nucleon][:action][:project_add][:class] = Nucleon::Action::Project::Add

    require loaded_plugins[:nucleon][:action][:extract][:file]
    loaded_plugins[:nucleon][:action][:extract][:class] = Nucleon::Action::Extract

    require loaded_plugins[:nucleon][:template][:json][:file]
    loaded_plugins[:nucleon][:template][:json][:class] = Nucleon::Template::JSON

    require loaded_plugins[:nucleon][:template][:yaml][:file]
    loaded_plugins[:nucleon][:template][:yaml][:class] = Nucleon::Template::YAML

    require loaded_plugins[:nucleon][:template][:wrapper][:file]
    loaded_plugins[:nucleon][:template][:wrapper][:class] = Nucleon::Template::Wrapper

    loaded_plugins
  end


  let(:plugin_test_environment) do
    plugin_directory = File.join(plugin_base_path, 'spec', 'nucleon')
    test_directory   = File.join(plugin_directory, 'test')

    {
      :plugin_types => {
        :nucleon => { :test => :first }
      },
      :load_info => {
        :nucleon => {
          :test => {
            :first => {
              :namespace        => :nucleon,
              :type             => :test,
              :base_path        => test_directory,
              :file             => File.join(test_directory, 'first.rb'),
              :provider         => :first,
              :directory        => test_directory,
              :class_components => [ "Nucleon", "Test", "First" ]
            },
            :second => {
              :namespace        => :nucleon,
              :type             => :test,
              :base_path        => test_directory,
              :file             => File.join(test_directory, 'second.rb'),
              :provider         => :second,
              :directory        => test_directory,
              :class_components => [ "Nucleon", "Test", "Second" ]
            }
          }
        }
      },
      :active_info => {}
    }
  end

  let(:plugin_environment_test1) do {
      :plugin_types => {
        :nucleon => {
          :test => :first
        }
      },
      :load_info    => {},
      :active_info  => {}
    }
  end

  let(:plugin_environment_test2) do {
      :plugin_types => {
        :nucleon => {
          :test1 => "test2",
          :test3 => "test4"
        }
      },
      :load_info   => {},
      :active_info => {}
    }
  end


  def plugin_define_test_environment(environment)
    plugin_path = File.join(plugin_base_path, 'spec', 'nucleon', 'test')

    environment.define_plugin_type(:nucleon, :test, :first)
    environment.define_plugin(:nucleon, :test, plugin_path, File.join(plugin_path, "first.rb"))
    environment.define_plugin(:nucleon, :test, plugin_path, File.join(plugin_path, "second.rb"))

    test_config environment, plugin_test_environment
    environment
  end


  let(:plugin_test_autoload_environment) do
    test_plugins = Nucleon::Util::Data.clone(plugin_test_environment)

    require test_plugins[:load_info][:nucleon][:test][:first][:file]
    test_plugins[:load_info][:nucleon][:test][:first][:class] = Nucleon::Test::First

    require test_plugins[:load_info][:nucleon][:test][:second][:file]
    test_plugins[:load_info][:nucleon][:test][:second][:class] = Nucleon::Test::Second

    test_plugins
  end

  def plugin_autoload_test_environment(environment)
    plugin_define_test_environment(environment)
    environment.autoload

    test_config environment, plugin_test_autoload_environment
    environment
  end
end
