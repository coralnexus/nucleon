
require 'spec_helper'

module Nucleon

  describe Core do

    include_context "test"
    include_context "config"


    #***************************************************************************

    def core(*args, &code)
      test_object(Core, *args, &code)
    end


    #***************************************************************************

    let(:core_object) { core(config_hash2) }


    #***************************************************************************
    # Constructor / Destructor

    # Initialize a new Nucleon core object
    #
    describe "#initialize" do

      it "creates via the default values if nil given as the primary data source" do
        test_config core(nil, config_hash1, true, true, true), config_hash1
        test_config core(nil, config_hash1, true, true, false), config_hash1
        test_config core(nil, config_hash1, true, false, true), config_hash1
        test_config core(nil, config_hash1, true, false, false), config_hash1

        test_config core(nil, config_hash1, false, true, true), config_hash1
        test_config core(nil, config_hash1, false, true, false), config_hash1
        test_config core(nil, config_hash1, false, false, true), config_hash1
        test_config core(nil, config_hash1, false, false, false), config_hash1
      end

      it "creates via a basic merge of hash with forced overwrites" do
        test_config core(config_hash2, config_hash1, true, true, true), config_hash_force_basic_merge
        test_config core(config_hash2, config_hash1, true, false, true), config_hash_force_basic_merge
      end
      it "creates via a deep merge of hash with forced overwrites" do
        test_config core(config_hash2, config_hash1, true, true, false), config_hash_force_deep_merge
        test_config core(config_hash2, config_hash1, true, false, false), config_hash_force_deep_merge
      end
      it "creates via a basic merge of hash with no forced overwrites" do
        test_config core(config_hash2, config_hash1, false, true, true), config_hash_no_force_basic_merge
        test_config core(config_hash2, config_hash1, false, false, true), config_hash_no_force_basic_merge
      end
      it "creates via a deep merge of hash with no forced overwrites" do
        test_config core(config_hash2, config_hash1, false, true, false), config_hash_no_force_deep_merge
        test_config core(config_hash2, config_hash1, false, false, false), config_hash_no_force_deep_merge
      end

      it "creates via a basic merge of Config object with forced overwrites" do
        test_config core(core_object, config_hash1, true, true, true), config_hash_force_basic_merge
        test_config core(core_object, config_hash1, true, false, true), config_hash_force_basic_merge
      end
      it "creates via a deep merge of Config object with forced overwrites" do
        test_config core(core_object, config_hash1, true, true, false), config_hash_force_deep_merge
        test_config core(core_object, config_hash1, true, false, false), config_hash_force_deep_merge
      end
      it "creates via a basic merge of Config object with no forced overwrites" do
        test_config core(core_object, config_hash1, false, true, true), config_hash_no_force_basic_merge
        test_config core(core_object, config_hash1, false, false, true), config_hash_no_force_basic_merge
      end
      it "creates via a deep merge of Config object with no forced overwrites" do
        test_config core(core_object, config_hash1, false, true, false), config_hash_no_force_deep_merge
        test_config core(core_object, config_hash1, false, false, false), config_hash_no_force_deep_merge
      end
    end


    #***************************************************************************
    # Checks

    # Check if object is initialized?
    #
    describe "#initialized?" do

      it "is true after initialization if set_initialized flag given" do
        test_eq core(config_hash2, config_hash1, true, true, true).initialized?, true
        test_eq core(config_hash2, config_hash1, true, true, false).initialized?, true
        test_eq core(config_hash2, config_hash1, false, true, true).initialized?, true
        test_eq core(config_hash2, config_hash1, false, true, false).initialized?, true
      end

      it "is false after initialization if set_initialized flag not given" do
        test_eq core(config_hash2, config_hash1, true, false, true).initialized?, false
        test_eq core(config_hash2, config_hash1, true, false, false).initialized?, false
        test_eq core(config_hash2, config_hash1, false, false, true).initialized?, false
        test_eq core(config_hash2, config_hash1, false, false, false).initialized?, false
      end
    end


    #***************************************************************************
    # Accessor / Modifiers

    # Return global logger instance
    #
    describe "#logger" do

      it "returns the global logger instance" do
        test_type Core.logger, Nucleon::Util::Logger
      end
    end

    # Set current object logger instance
    #
    describe "#logger=" do

      it "assigns instance logger from existing logger instance" do
        core(config_hash1, {}, true, true, true) do |core|
          logger      = test_object(Util::Logger, "test1")
          core.logger = logger

          test_eq logger == core.logger, true
          test_eq core.logger.resource == "test1", true
        end
      end

      it "assigns instance logger from new logger instance with specific name" do
        core(config_hash2, {}, true, true, true) do |core|
          core.logger = "test2"
          test_eq core.logger.resource == "test2", true
        end
      end
    end

    # Return global console instance
    #
    describe "#ui" do

      it "returns the global console instance" do
        test_type Core.ui, Nucleon::Util::Console
      end
    end

    # Set current object console instance
    #
    describe "#ui=" do

      it "assigns instance console from existing console instance" do
        core(config_hash1, {}, true, true, true) do |core|
          console = test_object(Util::Console, "test1")
          core.ui = console

          test_eq console == core.ui, true
          test_eq core.ui.resource == "test1", true
        end
      end

      it "assigns instance console from new console instance with specific name" do
        core(config_hash2, {}, true, true, true) do |core|
          core.ui = "test2"
          test_eq core.ui.resource == "test2", true
        end
      end
    end


    #***************************************************************************
    # General utilities

    # Contextualize console operations in a code block with a given resource name.
    #
    describe "#ui_group" do

      it "prints a colored message with a set prefix to the console" do
        test_output("[\e\[36mtest string\e\[0m] -----------------------------------------------------") do |output|
          Core.ui_group("test string", :cyan) do |ui|
            ui.output = output
            ui.info("-----------------------------------------------------")
          end
        end
      end
    end
  end
end