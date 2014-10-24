require 'spec_helper'

module Nucleon

  describe Core do

    let(:test_hash1) { {
        :testkey => 'testval',
        :nestedkey => {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'no' ]
          },
          :x => 'hello',
          :y => 'again',
          :z => 'im done now'
        },
        :other => [ 1, 2, 3, 4 ],
        :array => [ 3, 6, 9 ]
      }
    }

    let(:test_hash2) { {
        :testkey1 => 'testval1',
        :nestedkey => {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'yes' ],
            :test3 => true
          },
          :z => 'whew'
        },
        :other => 56,
        :array => [ 12 ]
      }
    }

    let(:merge_hash_no_force_basic_merge) { {
        :testkey => 'testval',
        :nestedkey => {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'yes' ],
            :test3 => true
          },
          :z => 'whew'
        },
        :other => 56,
        :array => [ 12 ],
        :testkey1 => 'testval1'
      }
    }

    let(:merge_hash_force_basic_merge) { {
        :testkey => 'testval',
        :nestedkey => {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'yes' ],
            :test3 => true
          },
          :z => 'whew'
        },
        :other => 56,
        :array => [ 12 ],
        :testkey1 => 'testval1'
      }
    }

    let(:merge_hash_no_force_deep_merge) { {
        :testkey => 'testval',
        :nestedkey => {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'no', 'yes' ],
            :test3 => true
          },
          :x => 'hello',
          :y => 'again',
          :z => 'im done now'
        },
        :other => [ 1, 2, 3, 4 ],
        :array => [ 3, 6, 9, 12 ],
        :testkey1 => 'testval1'
      }
    }

    let(:merge_hash_force_deep_merge) { {
        :testkey => 'testval',
        :nestedkey => {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'no', 'yes' ],
            :test3 => true
          },
          :x => 'hello',
          :y => 'again',
          :z => 'whew'
        },
        :other => 56,
        :array => [ 3, 6, 9, 12 ],
        :testkey1 => 'testval1'
      }
    }

    let(:testobj) { Core.new(test_hash2) }

    #*****************************************************************************
    # Constructor / Destructor

    # Initialize a new core Nucleon object
    #

    describe "#initialize" do

      it "tests nil data param for return value with initialize" do

        expect(Core.new(nil, test_hash1, true, true, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, true, true, false).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, true, false, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, true, false, false).export).to eq(test_hash1)

        expect(Core.new(nil, test_hash1, false, true, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, false, true, false).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, false, false, true).export).to eq(test_hash1)
        expect(Core.new(nil, test_hash1, false, false, false).export).to eq(test_hash1)

      end

      it "tests Hash data param for return value with initialize" do

        expect(Core.new(test_hash2, test_hash1, true, true, true).export).to eq(merge_hash_force_basic_merge)
        expect(Core.new(test_hash2, test_hash1, true, true, false).export).to eq(merge_hash_force_deep_merge)
        expect(Core.new(test_hash2, test_hash1, true, false, true).export).to eq(merge_hash_force_basic_merge)
        expect(Core.new(test_hash2, test_hash1, true, false, false).export).to eq(merge_hash_force_deep_merge)

        expect(Core.new(test_hash2, test_hash1, false, true, true).export).to eq(merge_hash_no_force_basic_merge)
        expect(Core.new(test_hash2, test_hash1, false, true, false).export).to eq(merge_hash_no_force_deep_merge)
        expect(Core.new(test_hash2, test_hash1, false, false, true).export).to eq(merge_hash_no_force_basic_merge)
        expect(Core.new(test_hash2, test_hash1, false, false, false).export).to eq(merge_hash_no_force_deep_merge)

      end

      it "tests Core Object data param for return value with initialize" do

        expect(Core.new(testobj, test_hash1, true, true, true).export).to eq(merge_hash_force_basic_merge)
        expect(Core.new(testobj, test_hash1, true, true, false).export).to eq(merge_hash_force_deep_merge)
        expect(Core.new(testobj, test_hash1, true, false, true).export).to eq(merge_hash_force_basic_merge)
        expect(Core.new(testobj, test_hash1, true, false, false).export).to eq(merge_hash_force_deep_merge)

        expect(Core.new(testobj, test_hash1, false, true, true).export).to eq(merge_hash_no_force_basic_merge)
        expect(Core.new(testobj, test_hash1, false, true, false).export).to eq(merge_hash_no_force_deep_merge)
        expect(Core.new(testobj, test_hash1, false, false, true).export).to eq(merge_hash_no_force_basic_merge)
        expect(Core.new(testobj, test_hash1, false, false, false).export).to eq(merge_hash_no_force_deep_merge)

      end
    end

    #*****************************************************************************
    # Checks

    # Check if object is initialized?
    #

    describe "#initialized?" do

      it "tests true and false return value with initialized?" do

        expect(Core.new(test_hash2, test_hash1, true, true, true).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, true, true, false).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, true, false, true).initialized?).to eq false
        expect(Core.new(test_hash2, test_hash1, true, false, false).initialized?).to eq false

        expect(Core.new(test_hash2, test_hash1, false, true, true).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, false, true, false).initialized?).to eq true
        expect(Core.new(test_hash2, test_hash1, false, false, true).initialized?).to eq false
        expect(Core.new(test_hash2, test_hash1, false, false, false).initialized?).to eq false

      end
    end

    #*****************************************************************************
    # Accessor / Modifiers

    # Return global logger instance
    #

    describe "#logger" do

      it "tests logger instance return type" do

        expect(Core.logger).to be_kind_of(Nucleon::Util::Logger)

      end
    end

    # Set current object logger instance
    #

    describe "#logger=" do

      it "tests logger instance" do

        logger         = Util::Logger.new("test1")

        object1        = Core.new(test_hash1, {}, true, true, true)
        object1.logger = logger

        object2        = Core.new(test_hash2, {}, true, true, true)
        object2.logger = "test2"

        expect(logger == object1.logger).to eq true
        expect(object1.logger.resource == "test1").to eq true
        expect(object2.logger.resource == "test2").to eq true

      end
    end

    # Return global console instance
    #

    describe "#ui" do

      it "tests Console instance return type with ui" do
        expect(Core.ui).to be_kind_of(Nucleon::Util::Console)

      end
    end

    # Set current object console instance
    #

    describe "#ui=" do

      it "test Console instance return type with ui=" do

        console = Util::Console.new("test1")

        object1    = Core.new(test_hash1, {}, true, true, true)
        object1.ui = console

        object2    = Core.new(test_hash2, {}, true, true, true)
        object2.ui = "test2"

        expect(console == object1.ui).to eq true
        expect(object1.ui.resource == "test1").to eq true
        expect(object2.ui.resource == "test2").to eq true

      end
    end

    #*****************************************************************************
    # General utilities

    # Contextualize console operations in a code block with a given resource name.
    #

    describe "#ui_group" do

      it "tests console output with ui_group" do

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