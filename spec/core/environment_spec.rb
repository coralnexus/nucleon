require 'spec_helper'

module Nucleon

  describe Environment do

    include_context "nucleon_test"
    include_context "nucleon_plugin"
    
    
    #***************************************************************************
    
    def environment(*args, &code)
      test_object(Environment, *args, &code)
    end
    
    def test_loaded_plugin(environment, plugin_type, provider_map)
      plugin_define_plugins(environment, plugin_type, provider_map) do |type, provider|
        plugin_info = environment.loaded_plugin(:nucleon, type, provider)
        test_eq plugin_info, plugin_loaded_plugins[:nucleon][type][provider]
      end
    end

    def test_loaded_plugins(environment, plugin_type, provider_map)
      plugin_define_plugins(environment, plugin_type, provider_map)
      test_eq environment.loaded_plugins[:nucleon][plugin_type], plugin_loaded_plugins[:nucleon][plugin_type]    
    end
    
    def test_create_plugin(environment, plugin_type, provider, options)
      plugin_autoload_test_environment(environment)
      plugin = environment.create_plugin(:nucleon, plugin_type, provider, options)
      test_config plugin, options
    end
    
    def test_create_plugin_math(environment, plugin_type, provider, options, num1, num2, result)
      plugin_autoload_test_environment(environment)
      plugin = environment.create_plugin(:nucleon, plugin_type, provider, options)
      test_eq plugin.math(num1, num2), result
    end
    
    def test_get_plugin(environment, plugin_type, provider, options)
      plugin_autoload_test_environment(environment)
      environment.create_plugin(:nucleon, plugin_type, provider, options)
      test_config environment.get_plugin(:nucleon, plugin_type, provider), options
    end
    
    def test_remove_plugin(environment, plugin_type, provider, options)
      plugin_autoload_test_environment(environment)
      plugin = environment.create_plugin(:nucleon, plugin_type, provider, options)
      test_config environment.remove_plugin(:nucleon, plugin_type, plugin.plugin_instance_name), options
    end    
    
    


    #*****************************************************************************
    # Constructor / Destructor
  
    describe "#initialize" do
      
      it "tests initialize method" do
        test_config environment, plugin_environment_empty
      end
    end
    
    #*****************************************************************************
    # Plugin type accessor / modifiers
  
    describe "#namespaces" do
        
      it "tests namespaces with empty array values" do
        test_eq environment.namespaces,[]
      end
      
      it "tests namespaces with array values" do
        environment do |environment|
          environment.define_plugin_type :nucleon, :test, :first
          environment.define_plugin_type :unit, :test, :first
          environment.define_plugin_type :testing, :test, :first
          test_eq environment.namespaces, [:nucleon, :unit, :testing]
        end
      end 
    end
    
    describe "#plugin_types" do
      
      it "returns an empty array when no plugin types are defined" do
          test_eq environment.plugin_types(:nucleon),[]
      end
      
      it "returns the existing plugin types for a namespace when given an existing namespace" do
        environment do |environment|
          environment.define_plugin_type :nucleon, :test, :first
          test_eq environment.plugin_types(:nucleon), [:test]
        end
      end
      
      it "returns an empty array when plugin types are defined but specified namespace does not exist" do
        environment do |environment|
          environment.define_plugin_type :nucleon, :test, :first
          test_eq environment.plugin_types(:nonexist), []
        end
      end
    end
    
    # Define a new plugin type in a specified namespace.
    #
  
    describe "#define_plugin_type" do
      
      it "returns loaded plugins state" do
          test_config environment.define_plugin_type(:nucleon, :test, :first), plugin_environment_test1
      end  
    end
    
    # Define one or more new plugin types in a specified namespace.
    #
    
    describe "#define_plugin_types" do
      
      it "returns loaded plugins state" do
        test_config environment.define_plugin_types(:nucleon, { :test1 => "test2", :test3 => "test4"}),plugin_environment_test2
      end
      
      it "returns environment object" do
        test_type environment.define_plugin_types(:nucleon, { :test1 => "test2", :test3 => "test4"}), Nucleon::Environment
      end
    end
    
    # Check if a specified plugin type has been defined
    #
    
    describe "#plugin_type_defined?" do
      
      it "returns true for defined plugins" do
        environment do |environment|
          environment.define_plugin_type(:nucleon, :test, :first)
          test_eq environment.plugin_type_defined?(:nucleon, :test),true
        end
      end
      
      it "returns false for undefined plugins" do
        environment do |environment|
          environment.define_plugin_type(:nucleon, :test, :first)
          test_eq environment.plugin_type_defined?(:notavail, :test),false
        end  
      end
    end
      
    # Return the default provider currently registered for a plugin type
    #
  
    describe "#plugin_type_default" do
      
      it "returns default provider using define_plugin_type" do
        environment do |environment|
          environment.define_plugin_type(:nucleon, :test, :first)
          test_eq environment.plugin_type_default(:nucleon, :test),:first
        end
      end
      
      it "returns default provider using define_plugin_types" do
        environment do |environment|
          environment.define_plugin_types(:nucleon1, { :test1 => "test2", :test3 => "test4"})
          test_eq environment.plugin_type_default(:nucleon1, :test3),"test4"
        end
      end
    end
    
    #*****************************************************************************
    # Loaded plugin accessor / modifiers
  
    describe "#define_plugin" do
    
      it "registers translator plugins" do
        plugin_define_plugins(environment, :translator, { :json => 'JSON', :yaml => 'YAML' }) 
      end
      
       it "registers template plugins" do
        plugin_define_plugins(environment, :template, { :json => 'JSON', :yaml => 'YAML', :wrapper => 'wrapper' })
      end
      
      it "registers project plugins" do
        plugin_define_plugins(environment, :project, { :git => 'git', :github => 'github' })
      end
      
      it "registers extension plugins" do
        plugin_define_plugins(environment, :extension, { :project => 'project' })
      end
      
      it "registers event plugins" do
        plugin_define_plugins(environment, :event, { :regex => 'regex' })
      end
      
      it "registers command plugins" do
        plugin_define_plugins(environment, :command, { :bash => 'bash' })
      end
      
      it "registers action plugins" do
        plugin_define_plugins(environment, :action, { :project_update => [ 'project', 'update' ], :project_ceate => [ 'project', 'create' ], :project_save => [ 'project', 'save' ], 
                                             :project_remove => [ 'project', 'remove' ], :project_add => [ 'project',  'add' ],:extract => 'extract' }) 
      end
    end
    
    # Return the load information for a specified plugin provider if it exists
    #
  
    describe "#loaded_plugin" do
      
      it "load info of translator plugins" do
        test_loaded_plugin(environment, :translator, {:json => 'JSON', :yaml => 'YAML' })                
      end
      
      it "load info of template plugins" do
        test_loaded_plugin(environment, :template, { :json => 'JSON', :yaml => 'YAML', :wrapper => 'wrapper' })
      end
      
      it "load info of project plugins" do
        test_loaded_plugin(environment, :project, { :git => 'git', :github => 'github' })
      end
      
      it "load info of extension plugins" do
        test_loaded_plugin(environment, :extension, { :project => 'project' })
      end
      
      it "load info of event plugins" do
        test_loaded_plugin(environment, :event, { :regex => 'regex' })
      end
      
      it "load info of command plugins" do
        test_loaded_plugin(environment, :command, { :bash => 'bash' })
      end
      
      it "load info of action - project plugins" do
        plugin_define_plugins(environment, :action, { :project_update => [ 'project', 'update' ], :project_ceate => [ 'project', 'create' ], :project_save => [ 'project', 'save' ], 
                                                      :project_remove => [ 'project', 'remove' ], :project_add => [ 'project',  'add' ],:extract => 'extract' }) 
      end
    end
    
    # Return the load information for namespaces, plugin types, providers if it exists
    #
    
    describe "#loaded_plugins" do
      
      it "returns loaded plugins for nil params" do
        test_eq environment.loaded_plugins, {}
        environment do |environment|
          plugin_define_plugins(environment, :project, { :github => 'github', :git => 'git' })
          plugin_define_plugins(environment, :event, { :regex => 'regex' })
          plugin_define_plugins(environment, :extension, { :project => 'project' })
          plugin_define_plugins(environment, :command, { :bash => 'bash' })
          plugin_define_plugins(environment, :translator, { :json => 'JSON', :yaml => 'YAML' })
          plugin_define_plugins(environment, :action, { :project_update => [ 'project', 'update' ], :project_ceate => [ 'project', 'create' ], :project_save => [ 'project', 'save' ], 
                                             :project_remove => [ 'project', 'remove' ], :project_add => [ 'project',  'add' ],:extract => 'extract' }) 
          plugin_define_plugins(environment, :template, { :json => 'JSON', :yaml => 'YAML', :wrapper => 'wrapper' })
          
          test_eq environment.loaded_plugins, plugin_loaded_plugins
        end
        
      end
      
      it "returns loaded translator plugins provided namespace alone" do
         test_loaded_plugins environment, :translator,{ :json => 'JSON', :yaml => 'YAML' }
      end
      
      it "returns loaded template plugins provide namespace alone" do
         test_loaded_plugins environment, :template,{ :json => 'JSON', :wrapper => 'wrapper', :yaml => 'YAML' }
      end
      
      it "returns loaded project plugins provide namespace alone" do
         test_loaded_plugins environment, :project,{ :git => 'git', :github => 'github' }
      end
      
      it "returns loaded extension plugins provide namespace alone" do
         test_loaded_plugins environment, :extension,{ :project => 'project' }
      end

      it "returns loaded event plugins provide namespace alone" do
         test_loaded_plugins environment, :event,{ :regex => 'regex' }
      end
      
      it "returns loaded command plugins provide namespace alone" do
         test_loaded_plugins environment, :command,{ :bash => 'bash' }
      end
      
      it "returns action command plugins provide namespace alone" do
         test_loaded_plugins environment, :action,{ :project_update => [ 'project', 'update' ], :project_save => [ 'project', 'save' ], :project_remove => [ 'project', 'remove' ], 
                                                    :project_ceate => [ 'project', 'create' ],:project_add => [ 'project',  'add' ],:extract => 'extract' }
      end

      it "returns loaded translator plugins provided namespace and plugin type" do
         test_loaded_plugins environment, :translator,{ :json => 'JSON', :yaml => 'YAML' }
      end
      
      it "returns loaded template plugins provide namespace and plugin type" do
         test_loaded_plugins environment, :template,{ :json => 'JSON', :wrapper => 'wrapper', :yaml => 'YAML' }
      end
      
      it "returns loaded project plugins provide namespace and plugin type" do
         test_loaded_plugins environment, :project,{ :git => 'git', :github => 'github' }
      end
      
      it "returns loaded extension plugins provide namespace and plugin type" do
         test_loaded_plugins environment, :extension,{ :project => 'project' }
      end

      it "returns loaded event plugins provide namespace and plugin type" do
         test_loaded_plugins environment, :event,{ :regex => 'regex' }
      end
      
      it "returns loaded command plugins provide namespace and plugin type" do
         test_loaded_plugins environment, :command,{ :bash => 'bash' }
      end
      
      it "returns action command plugins provide namespace and plugin type" do
        test_loaded_plugins environment, :action,{ :project_update => [ 'project', 'update' ], :project_save => [ 'project', 'save' ], :project_remove => [ 'project', 'remove' ], 
                                                              :project_ceate => [ 'project', 'create' ],:project_add => [ 'project',  'add' ],:extract => 'extract' }
      end

      it "returns loaded translator plugins provided namespace ,plugin type and provider" do
         test_loaded_plugins environment, :translator,{ :json => 'JSON', :yaml => 'YAML' }
      end
      
      it "returns loaded template plugins provide namespace ,plugin type and provider" do
         test_loaded_plugins environment, :template,{ :json => 'JSON', :wrapper => 'wrapper', :yaml => 'YAML' }
      end
      
      it "returns loaded project plugins provide namespace ,plugin type and provider" do
         test_loaded_plugins environment, :project,{ :git => 'git', :github => 'github' }
      end
      
      it "returns loaded extension plugins provide namespace ,plugin type and provider" do
         test_loaded_plugins environment, :extension,{ :project => 'project' }
      end

      it "returns loaded event plugins provide namespace ,plugin type and provider" do
         test_loaded_plugins environment, :event,{ :regex => 'regex' }
      end
      
      it "returns loaded command plugins provide namespace ,plugin type and provider" do
         test_loaded_plugins environment, :command,{ :bash => 'bash' }
      end
      
      it "returns action command plugins provide namespace ,plugin type and provider" do
         test_loaded_plugins environment, :action,{ :project_update => [ 'project', 'update' ], :project_save => [ 'project', 'save' ], :project_remove => [ 'project', 'remove' ], 
                                                              :project_ceate => [ 'project', 'create' ],:project_add => [ 'project',  'add' ],:extract => 'extract' }
      end
    end
    
    # Check if a specified plugin type has been loaded
    #
        
    describe "#plugin_has_type?" do
      
      it "returns true for a loaded plugin type" do
        environment do |environment|
           plugin_define_plugins environment, :translator,{ :json => 'JSON', :yaml => 'YAML' }
           test_eq environment.plugin_has_type?(:nucleon, :translator), true
        end
       
      end
      
      it "returns false for a non loaded plugin type" do
        environment do |environment|
           plugin_define_plugins environment, :translator,{ :json => 'JSON', :yaml => 'YAML' }
           test_eq environment.plugin_has_type?(:nucleon, :action), false
        end
      end       
    end
    
    # Check if a specified plugin provider has been loaded
    #
  
    describe "#plugin_has_provider?" do
      
      it "returns true for a loded plugin and provider" do
         environment do |environment|
             plugin_define_plugins environment, :translator,{ :json => 'JSON' }
             test_eq environment.plugin_has_provider?(:nucleon, :translator, :json), true
         end
      end
  
      it "returns false for a non loded plugin and provider" do
         environment do |environment|
             plugin_define_plugins environment, :action,{ :project_update => [ 'project', 'update' ], :project_save => [ 'project', 'save' ], :project_remove => [ 'project', 'remove' ], 
                                                                :project_add => [ 'project',  'add' ],:extract => 'extract' }
             test_eq environment.plugin_has_provider?(:nucleon, :action, :project_ceate), false
         end
      end
    end  
    
    # Autoload all of the defined plugins
    #
        
    describe "#autoload" do
      
      it "tests autoloaded plugin export" do
        plugin_autoload_test_environment(environment)
      end
    end
    
    #*****************************************************************************
    # Active plugin accessor / modifiers
  
    describe "#create_plugin" do
      
      it "tests create plugin export value" do
        test_create_plugin environment, :test, :first, { :test1 => 13 }
      end
      
      it "tests create plugin math value" do
        test_create_plugin_math environment, :test, :first, { :test1 => 13 }, 12, 12, 3744
      end      
      
      it "tests create plugin export value" do
        test_create_plugin environment, :test, :second, { :test1 => 15 }
      end
      
      it "tests create plugin math value" do
        test_create_plugin_math environment, :test, :second, { :test1 => 15 }, 12, 12, 41
      end
    end
    
    # Return a plugin instance by name if it exists
    #
    
    describe "#get_plugin" do
      
      it "returns the created plugins 1" do
        test_get_plugin environment, :test, :first, { :test1 => 13 , :test2 => 5}
      end
      
      it "returns the created plugins 2" do
        test_get_plugin environment, :test, :second, { :test1 => 13 , :test2 => 5}
      end
    end
    
    # Remove a plugin instance from the environment
    #
    
    describe "#remove_plugin" do
      
      it "returns the instance removed from the environment" do
        test_remove_plugin environment, :test, :first, { :test1 => 13, :test2 => 5}  
      end
    end    
    
    # Return active plugins for namespaces, plugin types, providers if specified
    #
        
    describe "#active_plugins" do
      
      it "returns appropriate return type" do     
        environment do |environment|
          plugin_autoload_test_environment(environment)
          environment.create_plugin(:nucleon, :test, :first, { :test1 => 13, :test2 => 5})
          environment.create_plugin(:nucleon, :test, :second, { :test1 => 15 })
          test_type(environment.active_plugins, Hash)
          test_type(environment.active_plugins(:nucleon), Hash)
          test_type(environment.active_plugins(:nucleon, :test), Hash)
          test_type(environment.active_plugins(:nucleon, :test, :first), Hash)
          test_type((environment.active_plugins(:nucleon, :test)[:first_bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f]), Nucleon::Test::First)
        end
        
      end
      
      it "returns appropriate return value" do
        environment do |environment|
          plugin_autoload_test_environment(environment)
          environment.create_plugin(:nucleon, :test, :first, { :test1 => 13, :test2 => 5})
          environment.create_plugin(:nucleon, :test, :second, { :test1 => 15 })
          test_config((environment.active_plugins[:nucleon][:test][:first_bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f]), {:test1=>13, :test2=>5})
        end 
      end
    end
    
    #*****************************************************************************
    # Utilities
  
    # Return a fully formed class name as a string
    #
        
    describe "#class_name" do
      
      it "returns a fully formed class name as an array with array of symbols" do
        test_eq environment.class_name([:Nucleon, :Test, :First], '::',true), ["Nucleon", "Test", "First"]
      end
      
      it "returns a fully formed class name as string seperated by :: with array of symbols" do
        test_eq environment.class_name([:Nucleon, :Test, :First], '::',false), "Nucleon::Test::First"
      end
      
      it "returns a fully formed class name as an array with array of strings" do
        test_eq environment.class_name(["Nucleon", "Test", "First"], '::',true), ["Nucleon", "Test", "First"]
      end
      
      it "returns a fully formed class name as string seperated by .. with array of strings" do
        test_eq environment.class_name(["Nucleon", "Test", "First"], '..',false), "Nucleon..Test..First"
      end
    end
    
    
    # Return a fully formed class name as a machine usable constant
    #
        
    describe "#class_const" do
      
      it "returns a fully formed class name for array of symbols" do
        test_eq environment.class_const([:Nucleon,:Test,:First], '::'), Nucleon::Test::First
      end
      
      it "returns a fully formed class name for array of strings" do
        test_eq environment.class_const(["Nucleon", "Test", "First"], '::'), Nucleon::Test::First
      end
    end

    # Return a class constant representing a base plugin class generated from namespace and plugin_type.
    #  
    
    describe "#plugin_class" do
      
      it "returns a class constant representing a base plugin class given symbols" do
        test_eq environment.plugin_class(:nucleon, :action), Nucleon::Plugin::Action
      end
      
      it "returns a class constant representing a base plugin class given strings" do
        test_eq environment.plugin_class("nucleon", "translator"), Nucleon::Plugin::Translator
      end
    end
  end
end