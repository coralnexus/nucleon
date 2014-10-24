
require 'spec_helper'

module Nucleon

  describe Config do

    include_context "config"


    #***************************************************************************

    let(:config_object) { Config.new(config_hash2) }


    #***************************************************************************
    # Instance generators

    # Ensure the return of a Nucleon::Config object based on different inputs.
    #
    describe "#ensure" do

      it "creates with default values if nil given as the primary data source" do
        expect(Config.ensure(nil, config_hash1, true, true).export).to eq(config_hash1)
        expect(Config.ensure(nil, config_hash1, true, false).export).to eq(config_hash1)
        expect(Config.ensure(nil, config_hash1, false, true).export).to eq(config_hash1)
        expect(Config.ensure(nil, config_hash1, false, false).export).to eq(config_hash1)
      end

      it "creates via a basic merge of hash with forced overwrites" do
        expect(Config.ensure(config_hash2, config_hash1, true, true).export).to eq(config_hash_force_basic_merge)
      end
      it "creates via a deep merge of hash with forced overwrites" do
        expect(Config.ensure(config_hash2, config_hash1, true, false).export).to eq(config_hash_force_deep_merge)
      end
      it "creates via a basic merge of hash with no forced overwrites" do
        expect(Config.ensure(config_hash2, config_hash1, false, true).export).to eq(config_hash_no_force_basic_merge)
      end
      it "creates via a deep merge of hash with no forced overwrites" do
        expect(Config.ensure(config_hash2, config_hash1, false, false).export).to eq(config_hash_no_force_deep_merge)
      end

      it "creates via a basic merge of Config object with forced overwrites" do
        config = Config.ensure(config_object, config_hash1, true, true)
        expect(config.export).to eq(config_hash_force_basic_merge)
        expect(config == config_object).to eq true
      end
      it "creates via a deep merge of Config object with forced overwrites" do
        config = Config.ensure(config_object, config_hash1, true, false)
        expect(config.export).to eq(config_hash_force_deep_merge)
        expect(config == config_object).to eq true
      end
      it "creates via a basic merge of Config object with no forced overwrites" do
        config = Config.ensure(config_object, config_hash1, false, true)
        expect(config.export).to eq(config_hash_no_force_basic_merge)
        expect(config == config_object).to eq true
      end
      it "creates via a deep merge of Config object with no forced overwrites" do
        config = Config.ensure(config_object, config_hash1, false, false)
        expect(config.export).to eq(config_hash_no_force_deep_merge)
        expect(config == config_object).to eq true
      end
    end

    # Initialize a new configuration object with contextualized defaults from the global configuration option collection.
    #
    describe "#init" do

      it "creates with global contextual options only (multiple contexts, single hierarchy)" do
        expect(Config.init(nil, config_contexts1, config_context_hierarchy1, {}, true, true).export).to eq(config_context_options1)
      end
      it "creates with global contextual options only (multiple contexts, multiple hierarchies)" do
        expect(Config.init(nil, config_contexts2, config_context_hierarchy2, {}, true, true).export).to eq(config_context_options2)
      end
      it "creates with global contextual options only (single context, multiple hierarchies)" do
        expect(Config.init(nil, config_contexts3, config_context_hierarchy3, {}, true, true).export).to eq(config_context_options3)
      end

      it "creates via a basic merge of hash with forced overwrites (multiple contexts, single hierarchy)" do
        expect(Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, true, true).export).to eq(config_hash_context1_force_basic_merge)
      end
      it "creates via a deep merge of hash with forced overwrites (multiple contexts, single hierarchy)" do
        expect(Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, true, false).export).to eq(config_hash_context1_force_deep_merge)
      end
      it "creates via a basic merge of hash with no forced overwrites (multiple contexts, single hierarchy)" do
        expect(Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, false, true).export).to eq(config_hash_context1_no_force_basic_merge)
      end
      it "creates via a deep merge of hash with no forced overwrites (multiple contexts, single hierarchy)" do
        expect(Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, false, false).export).to eq(config_hash_context1_no_force_deep_merge)
      end

      it "creates via a basic merge of hash with forced overwrites (multiple contexts, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, true, true).export).to eq(config_hash_context2_force_basic_merge)
      end
      it "creates via a deep merge of hash with forced overwrites (multiple contexts, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, true, false).export).to eq(config_hash_context2_force_deep_merge)
      end
      it "creates via a basic merge of hash with no forced overwrites (multiple contexts, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, false, true).export).to eq(config_hash_context2_no_force_basic_merge)
      end
      it "creates via a deep merge of hash with no forced overwrites (multiple contexts, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, false, false).export).to eq(config_hash_context2_no_force_deep_merge)
      end

      it "creates via a basic merge of hash with forced overwrites (single context, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, true, true).export).to eq(config_hash_context3_force_basic_merge)
      end
      it "creates via a deep merge of hash with forced overwrites (single context, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, true, false).export).to eq(config_hash_context3_force_deep_merge)
      end
      it "creates via a basic merge of hash with no forced overwrites (single context, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, false, true).export).to eq(config_hash_context3_no_force_basic_merge)
      end
      it "creates via a deep merge of hash with no forced overwrites (single contexts, multiple hierarchies)" do
        expect(Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, false, false).export).to eq(config_hash_context3_no_force_deep_merge)
      end
    end

    # Initialize a new configuration object with contextualized defaults from the
    # global configuration option collection (no hierarchical support).
    #
    describe "#init_flat" do

      it "creates with global contextual options only (multiple contexts)" do
        expect(Config.init_flat(nil, config_flat_contexts1, {}, true, true).export).to eq(config_flat_context_options1)
      end
      it "creates with global contextual options only (single context)" do
        expect(Config.init_flat(nil, config_flat_contexts2, {}, true, true).export).to eq(config_flat_context_options2)
      end
    end


    #***************************************************************************
    # Constructor / Destructor

    # Initialize a new Nucleon core object
    #
    describe "#initialize" do

      it "creates with default values if nil given as the primary data source" do
        expect(Config.new(nil, config_hash1, true, true).export).to eq(config_hash1)
        expect(Config.new(nil, config_hash1, true, false).export).to eq(config_hash1)
        expect(Config.new(nil, config_hash1, false, true).export).to eq(config_hash1)
        expect(Config.new(nil, config_hash1, false, false).export).to eq(config_hash1)
      end

      it "creates via a basic merge of hash with forced overwrites" do
        expect(Config.new(config_hash2, config_hash1, true, true).export).to eq(config_hash_force_basic_merge)
      end
      it "creates via a deep merge of hash with forced overwrites" do
        expect(Config.new(config_hash2, config_hash1, true, false).export).to eq(config_hash_force_deep_merge)
      end
      it "creates via a basic merge of hash with no forced overwrites" do
        expect(Config.new(config_hash2, config_hash1, false, true).export).to eq(config_hash_no_force_basic_merge)
      end
      it "creates via a deep merge of hash with no forced overwrites" do
        expect(Config.new(config_hash2, config_hash1, false, false).export).to eq(config_hash_no_force_deep_merge)
      end

      it "creates via a basic merge of Config object with forced overwrites" do
        expect(Config.new(config_object, config_hash1, true, true).export).to eq(config_hash_force_basic_merge)
      end
      it "creates via a deep merge of Config object with forced overwrites" do
        expect(Config.new(config_object, config_hash1, true, false).export).to eq(config_hash_force_deep_merge)
      end
      it "creates via a basic merge of Config object with no forced overwrites" do
        expect(Config.new(config_object, config_hash1, false, true).export).to eq(config_hash_no_force_basic_merge)
      end
      it "creates via a deep merge of Config object with no forced overwrites" do
        expect(Config.new(config_object, config_hash1, false, false).export).to eq(config_hash_no_force_deep_merge)
      end
    end


    #***************************************************************************
    # Checks

    # Check whether or not this configuration object is empty.
    #
    describe "#empty?" do

      it "returns false if properties are in the configuration object" do
        expect(Config.new(config_hash1, {}, true, true).empty?).to eq false
      end

      it "returns true if the configuration object is empty" do
        expect(Config.new(nil, {}, true, true).empty?).to eq true
      end
    end

    # Check whether or not this configuration object has a specific key.
    #
    describe "#has_key?" do

      it "is true if a top level key exists in the configuration object" do
        config = Config.new(config_hash1, {}, true, true)
        expect(config.has_key?("testkey")).to eq true
        expect(config.has_key?(:testkey)).to eq true
      end
      it "is true if a nested key exists in the configuration object" do
        config = Config.new(config_hash1, {}, true, true)
        expect(config.has_key?([ "nestedkey", "a", "test1" ])).to eq true
        expect(config.has_key?([ :nestedkey, :a, :test1 ])).to eq true
        expect(config.has_key?([ "nestedkey", "a", :test1 ])).to eq true
        expect(config.has_key?([ :nestedkey, nil, :a, nil, :test1, nil ])).to eq true
      end

      it "is false if a top level key does not exist in the configuration object" do
        config = Config.new(config_hash1, {}, true, true)
        expect(config.has_key?("some_non_existent_key")).to eq false
        expect(config.has_key?(:some_non_existent_key)).to eq false
      end
      it "is false if a nested key does not exist in the configuration object" do
        config = Config.new(config_hash1, {}, true, true)
        expect(config.has_key?([ "nestedkey", "test5" ])).to eq false
        expect(config.has_key?([ :nestedkey, :test5 ])).to eq false
        expect(config.has_key?([ "nestedkey", :test5 ])).to eq false
        expect(config.has_key?([ :nestedkey, nil, :test5, nil ])).to eq false
      end
    end


    #***************************************************************************
    # Property accessors / modifiers

    # Return all of the keys for the configuration properties hash.
    #
    describe "#keys" do

      it "returns the top level property keys in the configuration object" do
        expect(Config.new(config_hash1, {}, true, true).keys).to eq [ :testkey, :nestedkey, :other, :array ]
        expect(Config.new(config_hash2, {}, true, true).keys).to eq [ :testkey1, :nestedkey, :other, :array ]
      end
    end

    # Fetch value for key path in the configuration object.
    #
    describe "#get" do

      it "returns an existing value for a top level property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true).get(:testkey, nil, false)).to eq 'testval'
        expect(Config.new(config_hash2, {}, true, true).get(:testkey1, nil, false)).to eq 'testval1'
      end
      it "returns an existing value for a nested property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, :test2 ], nil, false)).to eq [ 'no' ]
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, nil, :y, nil ], nil, false)).to eq 'again'
        expect(Config.new(config_hash2, {}, true, true).get([ :nestedkey, :a, :test1 ], nil, false)).to eq 'oh'
        expect(Config.new(config_hash2, {}, true, true).get([ :nestedkey, :a, nil, :test3, nil ], nil, false)).to eq true
      end

      it "returns a default value for a top level property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, false, false)).to eq false
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, 'string', false)).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, :symbol, false)).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, [ :a, :b, :c ], false)).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, { :a => :b }, false)).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, false, :test)).to eq false
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, '42', :test)).to eq true
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, 'string', :string)).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, :string, :string)).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, :symbol, :symbol)).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, 'symbol', :symbol)).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, [ :a, :b, :c ], :array)).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, :a, :array)).to eq([ :a ])
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, { :a => :b }, :hash)).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true).get(:testkey15, nil, :hash)).to eq({})
      end
      it "returns a default value for a nested property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], false, false)).to eq false
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], 'string', false)).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :symbol, false)).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], [ :a, :b, :c ], false)).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], { :a => :b }, false)).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], false, :test)).to eq false
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], '42', :test)).to eq true
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], 'string', :string)).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :string, :string)).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :symbol, :symbol)).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], 'symbol', :symbol)).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], [ :a, :b, :c ], :array)).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :a, :array)).to eq([ :a ])
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], { :a => :b }, :hash)).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], nil, :hash)).to eq({})
      end
    end

    # Fetch value for key path in the configuration object.
    #
    describe "#[]" do

      it "returns an existing value for a top level property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true)[:testkey, nil, false]).to eq 'testval'
        expect(Config.new(config_hash2, {}, true, true)[:testkey1, nil, false]).to eq 'testval1'
      end

      it "returns a default value for a top level property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, false, false]).to eq false
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, 'string', false]).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, :symbol, false]).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, [ :a, :b, :c ], false]).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, { :a => :b }, false]).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, false, :test]).to eq false
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, '42', :test]).to eq true
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, 'string', :string]).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, :string, :string]).to eq 'string'
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, :symbol, :symbol]).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, 'symbol', :symbol]).to eq :symbol
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, [ :a, :b, :c ], :array]).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, :a, :array]).to eq([ :a ])
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, { :a => :b }, :hash]).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true)[:testkey15, nil, :hash]).to eq({})
      end
    end

    # Fetch filtered array value for key path in the configuration object.
    #
    describe "#get_array" do

      it "returns an existing array for a top level property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true).get_array(:testkey, [])).to eq([ 'testval' ])
        expect(Config.new(config_hash2, {}, true, true).get_array(:testkey1, [])).to eq([ 'testval1' ])
      end
      it "returns an existing array for a nested property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, :a, :test2 ], [])).to eq([ 'no' ])
        expect(Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, nil, :y, nil ], [])).to eq([ 'again' ])
        expect(Config.new(config_hash2, {}, true, true).get_array([ :nestedkey, :a, :test1 ], [])).to eq([ 'oh' ])
        expect(Config.new(config_hash2, {}, true, true).get_array([ :nestedkey, :a, nil, :test3, nil ], [])).to eq([ true ])
      end

      it "returns a default array for a top level property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true).get_array(:testkey15, [ :a, :b, :c ])).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true).get_array(:testkey15, :a)).to eq([ :a ])
      end
      it "returns a default array for a nested property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, :a, nil, :unknown ], [ :a, :b, :c ])).to eq([ :a, :b, :c ])
        expect(Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, :a, nil, :unknown ], :a)).to eq([ :a ])
      end
    end

    # Fetch filtered hash value for key path in the configuration object.
    #
    describe "#get_hash" do

      it "returns an existing hash for a top level property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true).get_hash(:nestedkey, {})).to eq({
        :a => {
          :test1 => 'oh',
          :test2 => [ 'no' ]
        },
        :x => 'hello',
        :y => 'again',
        :z => 'im done now'
      })
        expect(Config.new(config_hash2, {}, true, true).get_hash(:nestedkey, {})).to eq({
        :a => {
          :test1 => 'oh',
          :test2 => [ 'yes' ],
          :test3 => true
        },
        :z => 'whew'
      })
      end
      it "returns an existing hash for a nested property from the configuration object if it exists" do
        expect(Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, :a ], {})).to eq({ :test1 => 'oh', :test2 => [ 'no' ]  })
        expect(Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, nil, :y, nil ], {})).to eq({})
        expect(Config.new(config_hash2, {}, true, true).get_hash([ :nestedkey, :a ], {})).to eq({ :test1 => 'oh', :test2 => [ 'yes' ], :test3 => true })
        expect(Config.new(config_hash2, {}, true, true).get_hash([ :nestedkey, :a, nil, :test3, nil ], {})).to eq({})
      end

      it "returns a default hash for a top level property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true).get_hash(:testkey15, { :a => :b })).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true).get_hash(:testkey15, nil)).to eq({})
      end
      it "returns a default hash for a nested property from the configuration object if it does not exist" do
        expect(Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, :a, nil, :unknown ], { :a => :b })).to eq({ :a => :b })
        expect(Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, :a, nil, :unknown ], nil)).to eq({})
      end
    end

    # Initialize value for key path in the configuration object if one does not
    # exist yet.
    #
    describe "#init" do

      it "sets a top level configuration property that does not exist yet" do
        expect(Config.new(config_hash1, {}, true, true).init(:other_property, 'testing').get(:other_property)).to eq 'testing'
        expect(Config.new(config_hash2, {}, true, true).init(:new_property, 'testing2').get(:new_property)).to eq 'testing2'
      end
      it "sets a nested configuration property that does not exist yet" do
        expect(Config.new(config_hash1, {}, true, true).init([ :nested_property, :abc ], [ 1, 2, 3 ]).get([ :nested_property, :abc ])).to eq([ 1, 2, 3 ])
        expect(Config.new(config_hash2, {}, true, true).init([ :nested_property, :abc ], [ 1, 2, 3 ]).get([ :nested_property, :abc ])).to eq([ 1, 2, 3 ])
      end

      it "leaves a top level configuration property untouched if it already exists" do
        expect(Config.new(config_hash1, {}, true, true).init(:other, 'testing').get(:other)).to eq([ 1, 2, 3, 4 ])
        expect(Config.new(config_hash2, {}, true, true).init(:other, 'testing').get(:other)).to eq 56
      end
      it "leaves a nested configuration property untouched if it already exists" do
        expect(Config.new(config_hash1, {}, true, true).init([ :nestedkey, :a ], { :a => :b }).get([ :nestedkey, :a ])).to eq({ :test1 => 'oh', :test2 => [ 'no' ] })
        expect(Config.new(config_hash2, {}, true, true).init([ :nestedkey, :a ], { :a => :b }).get([ :nestedkey, :a ])).to eq({ :test1 => 'oh', :test2 => [ 'yes' ], :test3 => true })
      end
    end

    # Set value for key path in the configuration object.
    #
    describe "#set" do

      it "creates a configuration property with a specified value" do
        expect(Config.new(config_hash1, {}, true, true).set("other_property", "onething", false).get(:other_property)).to eq 'onething'
        expect(Config.new(config_hash2, {}, true, true).set(:other_property, { "a" => :b }, false).get([ :other_property, :a ])).to eq :b
      end

      it "updates a configuration property with a specified value" do
        expect(Config.new(config_hash1, {}, true, true).set("other", "onething", false).get(:other)).to eq 'onething'
        expect(Config.new(config_hash2, {}, true, true).set(:nestedkey, { "a" => :b }, false).get([ :nestedkey, :a ])).to eq :b
      end

      it "removes a configuration property containing a nil value" do
        expect(Config.new(config_hash1, {}, true, true).set(:array, nil, true).keys).to eq([ :testkey, :nestedkey, :other ])
        expect(Config.new(config_hash2, {}, true, true).set(:array, nil, true).keys).to eq([ :testkey1, :nestedkey, :other ])
      end
    end

    # Set value for key in the configuration object.
    #
    describe "#[]=" do

      it "creates a configuration property with a specified value" do
        config1 = Config.new(config_hash1, {}, true, true)
        config1["other_property"] = "onething"

        config2 = Config.new(config_hash2, {}, true, true)
        config2[:other_property] = { "a" => :b }

        expect(config1.get(:other_property)).to eq 'onething'
        expect(config2.get([ :other_property, :a ])).to eq :b
      end

      it "updates a configuration property with a specified value" do
        config1 = Config.new(config_hash1, {}, true, true)
        config1["other"] = "onething"

        config2 = Config.new(config_hash2, {}, true, true)
        config2[:nestedkey] = { "a" => :b }

        expect(config1.get(:other)).to eq 'onething'
        expect(config2.get([ :nestedkey, :a ])).to eq :b
      end
    end

    # Delete key path from the configuration object.
    #
    describe "#delete" do

      it "removes a configuration property and returns existing value" do
        config1 = Config.new(config_hash1, {}, true, true)
        config2 = Config.new(config_hash2, {}, true, true)

        expect(config1.delete(:other, nil)).to eq([ 1, 2, 3, 4 ])
        expect(config1.keys).to eq([ :testkey, :nestedkey, :array ])

        expect(config2.delete(:array, nil)).to eq([ 12 ])
        expect(config2.keys).to eq([ :testkey1, :nestedkey, :other ])
      end

      it "returns a default value if configuration property doesn't exist" do
        expect(Config.new(config_hash1, {}, true, true).delete(:test57, :yummy)).to eq :yummy
        expect(Config.new(config_hash2, {}, true, true).delete(:test57, [ 1, 2, 3 ])).to eq([ 1, 2, 3 ])
      end
    end

    # Clear all properties from the configuration object.
    #
    describe "#clear" do

      it "removes all the configuration properties from the object" do
        expect(Config.new(config_hash1, {}, true, true).clear.export).to eq({})
        expect(Config.new(config_hash2, {}, true, true).clear.export).to eq({})
      end
    end


    #***************************************************************************
    # Import / Export

    # Import new property values into the configuration object. (override)
    #
    describe "#import" do

    # TODO: String and symbol lookup conditions (used in CORL)

      it "imports properties via a basic merge of hash with forced overwrites" do
        expect(Config.new({}, {}, true, true).import([ config_hash1, config_hash2 ]).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_hash1, {}, true, true).import(config_hash2).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_hash1, {}, false, false).import(config_hash2, { :force => true, :basic => true }).export).to eq(config_hash_force_basic_merge)
      end
      it "imports properties via a deep merge of hash with forced overwrites" do
        expect(Config.new({}, {}, true, false).import([ config_hash1, config_hash2 ]).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_hash1, {}, true, false).import(config_hash2).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_hash1, {}, false, true).import(config_hash2, { :force => true, :basic => false }).export).to eq(config_hash_force_deep_merge)
      end
      it "imports properties via a basic merge of hash with no forced overwrites" do
        expect(Config.new({}, {}, false, true).import([ config_hash1, config_hash2 ]).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_hash1, {}, false, true).import(config_hash2).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_hash1, {}, true, false).import(config_hash2, { :force => false, :basic => true }).export).to eq(config_hash_no_force_basic_merge)
      end
      it "imports properties via a deep merge of hash with no forced overwrites" do
        expect(Config.new({}, {}, false, false).import([ config_hash1, config_hash2 ]).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_hash1, {}, false, false).import(config_hash2).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_hash1, {}, true, true).import(config_hash2, { :force => false, :basic => false }).export).to eq(config_hash_no_force_deep_merge)
      end

      it "imports properties via a basic merge of Config object with forced overwrites" do
        expect(Config.new({}, {}, true, true).import([ config_hash1, config_object ]).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_hash1, {}, true, true).import(config_object).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_hash1, {}, false, false).import(config_object, { :force => true, :basic => true }).export).to eq(config_hash_force_basic_merge)
      end
      it "imports properties via a deep merge of Config object with forced overwrites" do
        expect(Config.new({}, {}, true, false).import([ config_hash1, config_object ]).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_hash1, {}, true, false).import(config_object).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_hash1, {}, false, true).import(config_object, { :force => true, :basic => false }).export).to eq(config_hash_force_deep_merge)
      end
      it "imports properties via a basic merge of Config object with no forced overwrites" do
        expect(Config.new({}, {}, false, true).import([ config_hash1, config_object ]).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_hash1, {}, false, true).import(config_object).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_hash1, {}, true, false).import(config_object, { :force => false, :basic => true }).export).to eq(config_hash_no_force_basic_merge)
      end
      it "imports properties via a deep merge of Config object with no forced overwrites" do
        expect(Config.new({}, {}, false, false).import([ config_hash1, config_object ]).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_hash1, {}, false, false).import(config_object).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_hash1, {}, true, true).import(config_object, { :force => false, :basic => false }).export).to eq(config_hash_no_force_deep_merge)
      end
    end

    # Set default property values in the configuration object if they don't exist.
    #
    describe "#defaults" do

    # TODO: String and symbol lookup conditions (used in CORL)

      it "imports default properties via a basic merge of hash with forced overwrites" do
        expect(Config.new({}, {}, true, true).defaults([ config_hash2, config_hash1 ]).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_hash2, {}, true, true).defaults(config_hash1).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_hash2, {}, false, false).defaults(config_hash1, { :force => true, :basic => true }).export).to eq(config_hash_force_basic_merge)
      end
      it "imports default properties via a deep merge of hash with forced overwrites" do
        expect(Config.new({}, {}, true, false).defaults([ config_hash2, config_hash1 ]).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_hash2, {}, true, false).defaults(config_hash1).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_hash2, {}, false, true).defaults(config_hash1, { :force => true, :basic => false }).export).to eq(config_hash_force_deep_merge)
      end
      it "imports default properties via a basic merge of hash with no forced overwrites" do
        expect(Config.new({}, {}, false, true).defaults([ config_hash2, config_hash1 ]).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_hash2, {}, false, true).defaults(config_hash1).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_hash2, {}, true, false).defaults(config_hash1, { :force => false, :basic => true }).export).to eq(config_hash_no_force_basic_merge)
      end
      it "imports default properties via a deep merge of hash with no forced overwrites" do
        expect(Config.new({}, {}, false, false).defaults([ config_hash2, config_hash1 ]).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_hash2, {}, false, false).defaults(config_hash1).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_hash2, {}, true, true).defaults(config_hash1, { :force => false, :basic => false }).export).to eq(config_hash_no_force_deep_merge)
      end

      it "imports default properties via a basic merge of Config object with forced overwrites" do
        expect(Config.new({}, {}, true, true).defaults([ config_object, config_hash1 ]).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_object, {}, true, true).defaults(config_hash1).export).to eq(config_hash_force_basic_merge)
        expect(Config.new(config_object, {}, false, false).defaults(config_hash1, { :force => true, :basic => true }).export).to eq(config_hash_force_basic_merge)
      end
      it "imports default properties via a deep merge of Config object with forced overwrites" do
        expect(Config.new({}, {}, true, false).defaults([ config_object, config_hash1 ]).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_object, {}, true, false).defaults(config_hash1).export).to eq(config_hash_force_deep_merge)
        expect(Config.new(config_object, {}, false, true).defaults(config_hash1, { :force => true, :basic => false }).export).to eq(config_hash_force_deep_merge)
      end
      it "imports default properties via a basic merge of Config object with no forced overwrites" do
        expect(Config.new({}, {}, false, true).defaults([ config_object, config_hash1 ]).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_object, {}, false, true).defaults(config_hash1).export).to eq(config_hash_no_force_basic_merge)
        expect(Config.new(config_object, {}, true, false).defaults(config_hash1, { :force => false, :basic => true }).export).to eq(config_hash_no_force_basic_merge)
      end
      it "imports default properties via a deep merge of Config object with no forced overwrites" do
        expect(Config.new({}, {}, false, false).defaults([ config_object, config_hash1 ]).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_object, {}, false, false).defaults(config_hash1).export).to eq(config_hash_no_force_deep_merge)
        expect(Config.new(config_object, {}, true, true).defaults(config_hash1, { :force => false, :basic => false }).export).to eq(config_hash_no_force_deep_merge)
      end
    end

    # Export properties into a regular hash object (cloned)
    #
    describe "#export" do

      it "returns all configuration properties as a symbolized hash" do
        expect(Config.new(config_hash1, {}, true, true).export).to eq(config_hash1)
        expect(Config.new(config_hash2, {}, true, true).export).to eq(config_hash2)
      end
    end


    #***************************************************************************
    # Utilities

    # Return hash as a symbol map.
    #
    describe "#symbol_map" do

      it "returns a hash with recursively symbolized keys" do
        expect(Config.symbol_map(config_mixed_hash)).to eq(config_symbolized_hash)
      end
    end

    # Return hash as a string map.
    #
    describe "#string_map" do

      it "returns a hash with recursively stringified keys" do
        expect(Config.string_map(config_mixed_hash)).to eq(config_stringified_hash)
      end
    end


    #***************************************************************************

    # Run a defined filter on a data object.
    #
    describe "#filter" do

      it "returns given value when not filtered" do
        expect(Config.filter(true, false)).to eq true
        expect(Config.filter("string", false)).to eq "string"
        expect(Config.filter(:symbol, false)).to eq :symbol
        expect(Config.filter([ "test", "array" ], false)).to eq([ "test", "array" ])
        expect(Config.filter({ :a => :b }, false)).to eq({ :a => :b })
      end
      it "returns a boolean when filtered for a test condition" do
        expect(Config.filter(2 == 2, :test)).to eq true
        expect(Config.filter(2 == 5, :test)).to eq false
        expect(Config.filter("hello", :test)).to eq true
        expect(Config.filter([ '1' ], :test)).to eq true
        expect(Config.filter([], :test)).to eq false
        expect(Config.filter({ "a" => "b" }, :test)).to eq true
        expect(Config.filter({}, :test)).to eq false
      end
      it "returns a string when filtered for a string" do
        expect(Config.filter("string", :string)).to eq "string"
        expect(Config.filter(:symbol, :string)).to eq "symbol"
        expect(Config.filter(true, :string)).to eq "true"
        expect(Config.filter([ 1, 2, 3 ], :string)).to eq "[1, 2, 3]"
        expect(Config.filter({ :a => :b }, :string)).to eq "{:a=>:b}"
      end
      it "returns a symbol when filtered for a symbol" do
        expect(Config.filter("string", :symbol)).to eq :string
        expect(Config.filter(:symbol, :symbol)).to eq :symbol
        expect(Config.filter(true, :symbol)).to eq :true
      end
      it "returns an array when filtered for a array" do
        expect(Config.filter(nil, :array)).to eq([])
        expect(Config.filter("test", :array)).to eq([ "test" ])
        expect(Config.filter([ "test", "array" ], :array)).to eq([ "test", "array" ])
      end
      it "returns a hash when filtered for a hash" do
        expect(Config.filter(nil, :hash)).to eq({})
        expect(Config.filter("test", :hash)).to eq({})
        expect(Config.filter({ :a => :b }, :hash)).to eq({ :a => :b })
      end
    end


    #***************************************************************************

    # Ensure a data object is an array.
    #
    describe "#array" do

      it "returns a filtered array" do
        expect(Config.filter(nil, :array)).to eq([])
        expect(Config.filter("test", :array)).to eq([ "test" ])
        expect(Config.filter([ "test", "array" ], :array)).to eq([ "test", "array" ])
      end
    end

    # Ensure a data object is a hash.
    #
    describe "#hash" do

      it "returns a filtered hash" do
        expect(Config.filter(nil, :hash)).to eq({})
        expect(Config.filter("test", :hash)).to eq({})
        expect(Config.filter({ :a => :b }, :hash)).to eq({ :a => :b })
      end
    end

    # Ensure a data object is a string.
    #
    describe "#string" do

      it "returns a filtered string" do
        expect(Config.filter("string", :string)).to eq "string"
        expect(Config.filter(:symbol, :string)).to eq "symbol"
        expect(Config.filter(true, :string)).to eq "true"
        expect(Config.filter([ 1, 2, 3 ], :string)).to eq "[1, 2, 3]"
        expect(Config.filter({ :a => :b }, :string)).to eq "{:a=>:b}"
      end
    end

    # Ensure a data object is a symbol.
    #
    describe "#symbol" do

      it "returns a filtered symbol" do
        expect(Config.filter("string", :symbol)).to eq :string
        expect(Config.filter(:symbol, :symbol)).to eq :symbol
        expect(Config.filter(true, :symbol)).to eq :true
      end
    end

    # Test a data object for emptiness and return boolean result.
    #
    describe "#test" do

      it "returns a filtered boolean" do
        expect(Config.filter(2 == 2, :test)).to eq true
        expect(Config.filter(2 == 5, :test)).to eq false
        expect(Config.filter("hello", :test)).to eq true
        expect(Config.filter([ '1' ], :test)).to eq true
        expect(Config.filter([], :test)).to eq false
        expect(Config.filter({ "a" => "b" }, :test)).to eq true
        expect(Config.filter({}, :test)).to eq false
      end
    end
  end
end