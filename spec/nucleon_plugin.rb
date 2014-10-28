
RSpec.shared_context "nucleon_plugin" do

  #*****************************************************************************
  # Plugin environment data

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
    plugin_directory = File.join(File.expand_path('..', File.dirname(__FILE__)), 'lib', 'core', '..', 'nucleon')

    project_directory    = File.join(plugin_directory, 'project')
    event_directory      = File.join(plugin_directory, 'event')
    extension_directory  = File.join(plugin_directory, 'extension')
    command_directory    = File.join(plugin_directory, 'command')
    translator_directory = File.join(plugin_directory, 'translator')
    action_directory     = File.join(plugin_directory, 'action')
    template_directory   = File.join(plugin_directory, 'template')

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
            :class_components => [ "Nucleon", "Project", "Github" ],
            :class            => Nucleon::Project::Github
          },
          :git => {
            :namespace        => :nucleon,
            :type             => :project,
            :base_path        => project_directory,
            :file             => File.join(project_directory, 'git.rb'),
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
            :file             => File.join(event_directory, 'regex.rb'),
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
            :file             => File.join(extension_directory, 'project.rb'),
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
            :file             => File.join(command_directory, 'bash.rb'),
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
            :file             => File.join(translator_directory, 'JSON.rb'),
            :provider         => :json,
            :directory        => translator_directory,
            :class_components => [ "Nucleon", "Translator", "JSON" ],
            :class            => Nucleon::Translator::JSON
          },
          :yaml => {
            :namespace        => :nucleon,
            :type             => :translator,
            :base_path        => translator_directory,
            :file             => File.join(translator_directory, 'YAML.rb'),
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
            :file             => File.join(action_directory, 'project', 'update.rb'),
            :provider         => :project_update,
            :directory        => File.join(action_directory, 'project'),
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
            :file             => File.join(action_directory, 'project', 'create.rb'),
            :provider         => :project_create,
            :directory        => File.join(action_directory, 'project'),
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
            :file             => File.join(action_directory, 'project', 'save.rb'),
            :provider         => :project_save,
            :directory        => File.join(action_directory, 'project'),
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
            :file             => File.join(action_directory, 'project', 'remove.rb'),
            :provider         => :project_remove,
            :directory        => File.join(action_directory, 'project'),
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
            :file             => File.join(action_directory, 'project', 'add.rb'),
            :provider         => :project_add,
            :directory        => File.join(action_directory, 'project'),
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
            :file             => File.join(action_directory, 'extract.rb'),
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
            :file             => File.join(template_directory, 'JSON.rb'),
            :provider         => :json,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "JSON" ],
            :class            => Nucleon::Template::JSON
          },
          :yaml => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => File.join(template_directory, 'YAML.rb'),
            :provider         => :yaml,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "YAML" ],
            :class            => Nucleon::Template::YAML
          },
          :wrapper => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => File.join(template_directory, 'wrapper.rb'),
            :provider         => :wrapper,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "Wrapper" ],
            :class            => Nucleon::Template::Wrapper
          },
          :environment => {
            :namespace        => :nucleon,
            :type             => :template,
            :base_path        => template_directory,
            :file             => File.join(template_directory, 'environment.rb'),
            :provider         => :environment,
            :directory        => template_directory,
            :class_components => [ "Nucleon", "Template", "Environment" ],
            :class            => Nucleon::Template::Environment
          }
        }
      }
    }
  end
end