
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

  let(:plugin_loaded_plugins) do
    # Keep base directory out of data object as it might change with testing platform
    base_directory   = File.expand_path('..', File.dirname(__FILE__))
    plugin_directory = File.join('lib', 'nucleon')

    # Simulate autoloading
    project_directory    = File.join(plugin_directory, 'project')
    project_git_file     = File.join(project_directory, 'git.rb')
    require File.join(base_directory, project_git_file)
    
    project_github_file  = File.join(project_directory, 'github.rb')
    require File.join(base_directory, project_github_file)
    
    event_directory      = File.join(plugin_directory, 'event')
    event_regex_file     = File.join(event_directory, 'regex.rb')
    require File.join(base_directory, event_regex_file)
    
    extension_directory    = File.join(plugin_directory, 'extension')
    extension_project_file = File.join(extension_directory, 'project.rb')
    require File.join(base_directory, extension_project_file)
    
    command_directory    = File.join(plugin_directory, 'command')
    command_bash_file    = File.join(command_directory, 'bash.rb')
    require File.join(base_directory, command_bash_file)
    
    translator_directory = File.join(plugin_directory, 'translator')
    translator_json_file = File.join(translator_directory, 'JSON.rb')
    require File.join(base_directory, translator_json_file)
    
    translator_yaml_file = File.join(translator_directory, 'YAML.rb')
    require File.join(base_directory, translator_yaml_file)
    
    action_directory           = File.join(plugin_directory, 'action')
    action_project_directory   = File.join(action_directory, 'project')
    
    action_project_update_file = File.join(action_project_directory, 'update.rb')
    require File.join(base_directory, action_project_update_file)
    
    action_project_create_file = File.join(action_project_directory, 'create.rb')
    require File.join(base_directory, action_project_create_file)
    
    action_project_save_file = File.join(action_project_directory, 'save.rb')
    require File.join(base_directory, action_project_save_file)
    
    action_project_remove_file = File.join(action_project_directory, 'remove.rb')
    require File.join(base_directory, action_project_remove_file)
    
    action_project_add_file = File.join(action_project_directory, 'add.rb')
    require File.join(base_directory, action_project_add_file)
    
    action_extract_file = File.join(action_directory, 'extract.rb')
    require File.join(base_directory, action_extract_file)
    
    template_directory   = File.join(plugin_directory, 'template')
    template_json_file   = File.join(template_directory, 'JSON.rb')
    require File.join(base_directory, template_json_file)
    
    template_yaml_file   = File.join(template_directory, 'YAML.rb')
    require File.join(base_directory, template_yaml_file)
    
    template_wrapper_file = File.join(template_directory, 'wrapper.rb')
    require File.join(base_directory, template_wrapper_file)
    
    template_environment_file = File.join(template_directory, 'environment.rb')
    require File.join(base_directory, template_environment_file)

    {
      :nucleon => {
        :project => {
          :github => {
            :namespace        => :nucleon,
            :type             => :project,
            :base_path        => project_directory,
            :file             => project_github_file,
            :provider         => :github,
            :directory        => project_directory,
            :class_components => [ "Nucleon", "Project", "Github" ],
            :class            => Nucleon::Project::Github
          },
          :git => {
            :namespace        => :nucleon,
            :type             => :project,
            :base_path        => project_directory,
            :file             => project_git_file,
            :provider         => :git,
            :directory        => project_directory,
            :class_components => [ "Nucleon", "Project", "Git" ],
            :class            => Nucleon::Project::Git
          }
        },
        :event => {
          :regex => {
            :namespace        => :nucleon,
            :type             => :event,
            :base_path        => event_directory,
            :file             => event_regex_file,
            :provider         => :regex,
            :directory        => event_directory,
            :class_components => ["Nucleon", "Event", "Regex"],
            :class            => Nucleon::Event::Regex
          }
        },
        :extension => {
          :project => {
            :namespace        => :nucleon,
            :type             => :extension,
            :base_path        => extension_directory,
            :file             => extension_project_file,
            :provider         => :project,
            :directory        => extension_directory,
            :class_components => ["Nucleon", "Extension", "Project"],
            :class            => Nucleon::Extension::Project
          }
        },
        :command => {
          :bash => {
            :namespace        => :nucleon,
            :type             => :command,
            :base_path        => command_directory,
            :file             => command_bash_file,
            :provider         => :bash,
            :directory        => command_directory,
            :class_components => ["Nucleon", "Command", "Bash"],
            :class            => Nucleon::Command::Bash
          }
        },
        :translator => {
          :json => {
            :namespace        => :nucleon,
            :type             => :translator,
            :base_path        => translator_directory,
            :file             => translator_json_file,
            :provider         => :json,
            :directory        => translator_directory,
            :class_components => [ "Nucleon", "Translator", "JSON" ],
            :class            => Nucleon::Translator::JSON
          },
          :yaml => {
            :namespace        => :nucleon,
            :type             => :translator,
            :base_path        => translator_directory,
            :file             => translator_yaml_file,
            :provider         => :yaml,
            :directory        => translator_directory,
            :class_components => [ "Nucleon", "Translator", "YAML" ],
            :class            => Nucleon::Translator::YAML
          }
        },
        :action => {
          :project_update => {
            :namespace        => :nucleon,
            :type             => :action,
            :base_path        => action_directory,
            :file             => action_project_update_file,
            :provider         => :project_update,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Update" ],
            :class            => Nucleon::Action::Project::Update,
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
            :file             => action_project_create_file,
            :provider         => :project_create,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Create" ],
            :class            => Nucleon::Action::Project::Create,
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
            :file             => action_project_save_file,
            :provider         => :project_save,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Save" ],
            :class            => Nucleon::Action::Project::Save,
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
            :file             => action_project_remove_file,
            :provider         => :project_remove,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Remove" ],
            :class            => Nucleon::Action::Project::Remove,
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
            :file             => action_project_add_file,
            :provider         => :project_add,
            :directory        => action_project_directory,
            :class_components => [ "Nucleon", "Action", "Project", "Add" ],
            :class            => Nucleon::Action::Project::Add,
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
            :file             => action_extract_file,
            :provider         => :extract,
            :directory        => action_directory,
            :class_components => [ "Nucleon", "Action", "Extract" ],
            :class            => Nucleon::Action::Extract,
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
            :file             => template_json_file,
            :provider         => :json,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "JSON" ],
            :class            => Nucleon::Template::JSON
          },
          :yaml => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => template_yaml_file,
            :provider         => :yaml,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "YAML" ],
            :class            => Nucleon::Template::YAML
          },
          :wrapper => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => template_wrapper_file,
            :provider         => :wrapper,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "Wrapper" ],
            :class            => Nucleon::Template::Wrapper
          },
          :environment => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => template_environment_file,
            :provider         => :environment,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "Environment" ],
            :class            => Nucleon::Template::Environment
          }
        }
      }
    }
  end


  let(:plugin_active_plugins) do

  end
end
