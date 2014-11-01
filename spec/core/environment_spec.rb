require 'spec_helper'

module Nucleon

  describe Environment do

    include_context "nucleon_test"
    include_context "nucleon_plugin"
    
    
    #***************************************************************************

    def environment(*args, &code)
      test_object(Environment, *args, &code)
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
          test_config environment.define_plugin_type(:nucleon, :test, :first), {
                                                                                  :plugin_types=>{:nucleon=>{:test=>:first}}, 
                                                                                  :load_info=>{}, 
                                                                                  :active_info=>{}
                                                                               }
      end
      
    end
    
  # Define one or more new plugin types in a specified namespace.
  #
  
    describe "#define_plugin_types" do
      
      it "returns loaded plugins state" do
        test_config environment.define_plugin_types(:nucleon, { :test1 => "test2", :test3 => "test4"}),{
                                                                                                          :plugin_types=>{:nucleon=>{:test1=>"test2", :test3=>"test4"}}, 
                                                                                                          :load_info=>{}, 
                                                                                                          :active_info=>{}
                                                                                                         }
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
    
  end
  
end