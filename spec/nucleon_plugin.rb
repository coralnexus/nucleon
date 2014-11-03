
#
# Require test plugin type
#
require File.join(File.dirname(__FILE__), 'nucleon', 'test.rb')


RSpec.shared_context "nucleon_plugin" do

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
        :action     => :update,
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
    # Keep base directory out of data object as it might change with testing platform

    plugin_directory         = File.join('lib', 'nucleon')
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
            :class_components => [ "Nucleon", "Action", "Project", "Update" ],
            :description      => {
              :namespace   => :nucleon,
              :weight      => 900,
              :group       => :project,
              :action      => :update,
              :description => "Update this project from a remote",
              :help        => "translation missing: en.nucleon.action.project.update.help"
            },
            :_weight => 900
          },
          :project_create => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'create.rb'),
            :provider         => :project_create,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Create" ],
            :description      => {
              :namespace   => :nucleon,
              :weight      => 1000,
              :group       => :project,
              :action      => :create,
              :description => "Create a new project",
              :help        => "translation missing: en.nucleon.action.project.create.help"
            },
            :_weight => 1000
          },
          :project_save => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'save.rb'),
            :provider         => :project_save,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Save" ],
            :description      => {
              :namespace   => :nucleon,
              :weight      => 800,
              :group       => :project,
              :action      => :save,
              :description => "Save changes to files in this project",
              :help        => "translation missing: en.nucleon.action.project.save.help"
            },
            :_weight => 800
          },
          :project_remove => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'remove.rb'),
            :provider         => :project_remove,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Remove" ],
            :description      => {
              :namespace   => :nucleon,
              :weight      => 600,
              :group       => :project,
              :action      => :remove,
              :description => "Remove an existing sub-project from this project",
              :help        => "translation missing: en.nucleon.action.project.remove.help"
            },
            :_weight => 600
          },
          :project_add => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_project_directory, 'add.rb'),
            :provider         => :project_add,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Add" ],
            :description      => {
              :namespace   => :nucleon,
              :weight      => 700,
              :group       => :project,
              :action      => :add,
              :description => "Add a new sub-project to this project",
              :help        => "translation missing: en.nucleon.action.project.add.help"
            },
            :_weight => 700
          },
          :extract => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => File.join(action_directory, 'extract.rb'),
            :provider         => :extract,
            :directory        => action_directory,
            :class_components => [ "Nucleon", "Action", "Extract" ],
            :description      => {
              :namespace   => :nucleon,
              :weight      => -50,
              :group       => nil,
              :action      => :extract,
              :description => "Extract an encoded package into a directory",
              :help        => "translation missing: en.nucleon.action.extract.help"
            },
            :_weight => -50
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

  let(:plugin_autoload_plugins) do
    # Keep base directory out of data object as it might change with testing platform

    loaded_plugins = plugin_loaded_plugins

    # Simulate autoloading of defined plugins

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:project][:github][:file])
    loaded_plugins[:nucleon][:project][:github][:class] = Nucleon::Project::Github

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:project][:git][:file])
    loaded_plugins[:nucleon][:project][:git][:class] = Nucleon::Project::Git

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:event][:regex][:file])
    loaded_plugins[:nucleon][:event][:regex][:class] = Nucleon::Event::Regex

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:extension][:project][:file])
    loaded_plugins[:nucleon][:extension][:project][:class] = Nucleon::Extension::Project

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:command][:bash][:file])
    loaded_plugins[:nucleon][:command][:bash][:class] = Nucleon::Command::Bash

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:translator][:json][:file])
    loaded_plugins[:nucleon][:translator][:json][:class] = Nucleon::Translator::JSON

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:translator][:yaml][:file])
    loaded_plugins[:nucleon][:translator][:yaml][:class] = Nucleon::Translator::YAML

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:action][:project_update][:file])
    loaded_plugins[:nucleon][:action][:project_update][:class] = Nucleon::Action::Project::Update

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:action][:project_create][:file])
    loaded_plugins[:nucleon][:action][:project_create][:class] = Nucleon::Action::Project::Create

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:action][:project_save][:file])
    loaded_plugins[:nucleon][:action][:project_save][:class] = Nucleon::Action::Project::Save

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:action][:project_remove][:file])
    loaded_plugins[:nucleon][:action][:project_remove][:class] = Nucleon::Action::Project::Remove

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:action][:project_add][:file])
    loaded_plugins[:nucleon][:action][:project_add][:class] = Nucleon::Action::Project::Add

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:action][:extract][:file])
    loaded_plugins[:nucleon][:action][:extract][:class] = Nucleon::Action::Extract

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:template][:json][:file])
    loaded_plugins[:nucleon][:template][:json][:class] = Nucleon::Template::JSON

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:template][:yaml][:file])
    loaded_plugins[:nucleon][:template][:yaml][:class] = Nucleon::Template::YAML

    require File.join(plugin_base_path, loaded_plugins[:nucleon][:template][:wrapper][:file])
    loaded_plugins[:nucleon][:template][:wrapper][:class] = Nucleon::Template::Wrapper

    loaded_plugins
  end


  let(:plugin_active_plugins) do

  end
end
