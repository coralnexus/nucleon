
require 'spec_helper'

module Nucleon

  describe Core do
    include_context "config"

    let(:testobj) { Core.new(test_hash2) }

    #***************************************************************************
    # Constructor / Destructor

    # Initialize a new core Nucleon object
    #

    describe "#initialize" do

      it "via the default values if nil given as the primary data source" do

        expect(Core.new(nil, test_hash1, true, true, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, true, true, false).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, true, false, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, true, false, false).export).to eq(test_hash1)

        expect(Core.new(nil, test_hash1, false, true, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, false, true, false).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, false, false, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, false, false, false).export).to eq(test_hash1)

      end

      it "via a basic merge of hash with forced overwrites" do

        expect(Core.new(test_hash2, test_hash1, true, true, true).export).to eq(merge_hash_force_basic_merge)
        expect(Core.new(test_hash2, test_hash1, true, false, true).export).to eq(merge_hash_force_basic_merge)

      end

      it "via a deep merge of hash with forced overwrites" do

        expect(Core.new(test_hash2, test_hash1, true, true, false).export).to eq(merge_hash_force_deep_merge)
        expect(Core.new(test_hash2, test_hash1, true, false, false).export).to eq(merge_hash_force_deep_merge)

      end

      it "via a basic merge of hash with no forced overwrites" do

        expect(Core.new(test_hash2, test_hash1, false, true, true).export).to eq(merge_hash_no_force_basic_merge)
        expect(Core.new(test_hash2, test_hash1, false, false, true).export).to eq(merge_hash_no_force_basic_merge)

      end

      it "via a deep merge of hash with no forced overwrites" do

        expect(Core.new(test_hash2, test_hash1, false, true, false).export).to eq(merge_hash_no_force_deep_merge)
        expect(Core.new(test_hash2, test_hash1, false, false, false).export).to eq(merge_hash_no_force_deep_merge)

      end

      it "via a basic merge of Config object with forced overwrites" do

        expect(Core.new(testobj, test_hash1, true, true, true).export).to eq(merge_hash_force_basic_merge)
        expect(Core.new(testobj, test_hash1, true, false, true).export).to eq(merge_hash_force_basic_merge)

      end

      it "via a deep merge of Config object with forced overwrites" do

        expect(Core.new(testobj, test_hash1, true, true, false).export).to eq(merge_hash_force_deep_merge)
        expect(Core.new(testobj, test_hash1, true, false, false).export).to eq(merge_hash_force_deep_merge)

      end

      it "via a basic merge of Config object with no forced overwrites" do

        expect(Core.new(testobj, test_hash1, false, true, true).export).to eq(merge_hash_no_force_basic_merge)
        expect(Core.new(testobj, test_hash1, false, false, true).export).to eq(merge_hash_no_force_basic_merge)

      end

      it "via a deep merge of Config object with no forced overwrites" do

        expect(Core.new(testobj, test_hash1, false, true, false).export).to eq(merge_hash_no_force_deep_merge)
        expect(Core.new(testobj, test_hash1, false, false, false).export).to eq(merge_hash_no_force_deep_merge)

      end
    end

    #*****************************************************************************
    # Checks

    # Check if object is initialized?
    #

    describe "#initialized?" do

      it "is true after initialization if set_initialized flag given" do

        expect(Core.new(test_hash2, test_hash1, true, true, true).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, true, true, false).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, false, true, true).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, false, true, false).initialized?).to eq true

      end

      it "is false after initialization if set_initialized flag not given" do

        expect(Core.new(test_hash2, test_hash1, true, false, true).initialized?).to eq false
        expect(Core.new(test_hash2, test_hash1, true, false, false).initialized?).to eq false
        expect(Core.new(test_hash2, test_hash1, false, false, true).initialized?).to eq false
        expect(Core.new(test_hash2, test_hash1, false, false, false).initialized?).to eq false

      end
    end

    #*****************************************************************************
    # Accessor / Modifiers

    # Return global logger instance
    #

    describe "#logger" do

      it "returns the global logger instance" do

        expect(Core.logger).to be_kind_of(Nucleon::Util::Logger)

      end
    end

    # Set current object logger instance
    #

    describe "#logger=" do

      it "assigns instance logger from existing logger instance" do

        logger        = Util::Logger.new("test1")
        object        = Core.new(test_hash1, {}, true, true, true)
        object.logger = logger

        expect(logger == object.logger).to eq true
        expect(object.logger.resource == "test1").to eq true

      end

      it "assigns instance logger from new logger instance with specific name" do

        object        = Core.new(test_hash2, {}, true, true, true)
        object.logger = "test2"

        expect(object.logger.resource == "test2").to eq true

      end
    end

    # Return global console instance
    #

    describe "#ui" do

      it "returns the global console instance" do

        expect(Core.ui).to be_kind_of(Nucleon::Util::Console)

      end
    end

    # Set current object console instance
    #

    describe "#ui=" do

      it "assigns instance console from existing console instance" do

        console = Util::Console.new("test1")

        object    = Core.new(test_hash1, {}, true, true, true)
        object.ui = console

        expect(console == object.ui).to eq true
        expect(object.ui.resource == "test1").to eq true

      end

      it "assigns instance console from new console instance with specific name" do

        object    = Core.new(test_hash2, {}, true, true, true)
        object.ui = "test2"

        expect(object.ui.resource == "test2").to eq true

      end
    end

    #*****************************************************************************
    # General utilities

    # Contextualize console operations in a code block with a given resource name.
    #

    describe "#ui_group" do

      it "prints a colored message with a set prefix to the console" do

        output = double('output')
        expect(output).to receive(:puts).with(/^\[\e\[36mtest string\e\[0m\] -----------------------------------------------------$/)

        Core.ui_group("test string", :cyan) do |ui|
          ui.output = output
          ui.info("-----------------------------------------------------")
        end

      end
    end
  end
end