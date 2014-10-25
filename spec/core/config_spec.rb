
require 'spec_helper'

module Nucleon

  describe Config do

    include_context "test"
    include_context "config"


    #***************************************************************************

    let(:config_object) { Config.new(config_hash2) }


    #***************************************************************************
    # Instance generators

    # Ensure the return of a Nucleon::Config object based on different inputs.
    #
    describe "#ensure" do

      it "creates with default values if nil given as the primary data source" do
        test_config Config.ensure(nil, config_hash1, true, true), config_hash1
        test_config Config.ensure(nil, config_hash1, true, false), config_hash1
        test_config Config.ensure(nil, config_hash1, false, true), config_hash1
        test_config Config.ensure(nil, config_hash1, false, false), config_hash1
      end

      it "creates via a basic merge of hash with forced overwrites" do
        test_config Config.ensure(config_hash2, config_hash1, true, true), config_hash_force_basic_merge
      end
      it "creates via a deep merge of hash with forced overwrites" do
        test_config Config.ensure(config_hash2, config_hash1, true, false), config_hash_force_deep_merge
      end
      it "creates via a basic merge of hash with no forced overwrites" do
        test_config Config.ensure(config_hash2, config_hash1, false, true), config_hash_no_force_basic_merge
      end
      it "creates via a deep merge of hash with no forced overwrites" do
        test_config Config.ensure(config_hash2, config_hash1, false, false), config_hash_no_force_deep_merge
      end

      it "creates via a basic merge of Config object with forced overwrites" do
        config = Config.ensure(config_object, config_hash1, true, true)

        test_config config, config_hash_force_basic_merge
        test_eq config == config_object, true
      end
      it "creates via a deep merge of Config object with forced overwrites" do
        config = Config.ensure(config_object, config_hash1, true, false)

        test_config config, config_hash_force_deep_merge
        test_eq config == config_object, true
      end
      it "creates via a basic merge of Config object with no forced overwrites" do
        config = Config.ensure(config_object, config_hash1, false, true)

        test_config config, config_hash_no_force_basic_merge
        test_eq config == config_object, true
      end
      it "creates via a deep merge of Config object with no forced overwrites" do
        config = Config.ensure(config_object, config_hash1, false, false)

        test_config config, config_hash_no_force_deep_merge
        test_eq config == config_object, true
      end
    end

    # Initialize a new configuration object with contextualized defaults from the global configuration option collection.
    #
    describe "#init" do

      it "creates with global contextual options only (multiple contexts, single hierarchy)" do
        test_config Config.init(nil, config_contexts1, config_context_hierarchy1, {}, true, true), config_context_options1
      end
      it "creates with global contextual options only (multiple contexts, multiple hierarchies)" do
        test_config Config.init(nil, config_contexts2, config_context_hierarchy2, {}, true, true), config_context_options2
      end
      it "creates with global contextual options only (single context, multiple hierarchies)" do
        test_config Config.init(nil, config_contexts3, config_context_hierarchy3, {}, true, true), config_context_options3
      end

      it "creates via a basic merge of hash with forced overwrites (multiple contexts, single hierarchy)" do
        test_config Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, true, true), config_hash_context1_force_basic_merge
      end
      it "creates via a deep merge of hash with forced overwrites (multiple contexts, single hierarchy)" do
        test_config Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, true, false), config_hash_context1_force_deep_merge
      end
      it "creates via a basic merge of hash with no forced overwrites (multiple contexts, single hierarchy)" do
        test_config Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, false, true), config_hash_context1_no_force_basic_merge
      end
      it "creates via a deep merge of hash with no forced overwrites (multiple contexts, single hierarchy)" do
        test_config Config.init(config_hash1, config_contexts1, config_context_hierarchy1, config_context_default_data, false, false), config_hash_context1_no_force_deep_merge
      end

      it "creates via a basic merge of hash with forced overwrites (multiple contexts, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, true, true), config_hash_context2_force_basic_merge
      end
      it "creates via a deep merge of hash with forced overwrites (multiple contexts, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, true, false), config_hash_context2_force_deep_merge
      end
      it "creates via a basic merge of hash with no forced overwrites (multiple contexts, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, false, true), config_hash_context2_no_force_basic_merge
      end
      it "creates via a deep merge of hash with no forced overwrites (multiple contexts, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts2, config_context_hierarchy2, config_context_default_data, false, false), config_hash_context2_no_force_deep_merge
      end

      it "creates via a basic merge of hash with forced overwrites (single context, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, true, true), config_hash_context3_force_basic_merge
      end
      it "creates via a deep merge of hash with forced overwrites (single context, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, true, false), config_hash_context3_force_deep_merge
      end
      it "creates via a basic merge of hash with no forced overwrites (single context, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, false, true), config_hash_context3_no_force_basic_merge
      end
      it "creates via a deep merge of hash with no forced overwrites (single contexts, multiple hierarchies)" do
        test_config Config.init(config_hash1, config_contexts3, config_context_hierarchy3, config_context_default_data, false, false), config_hash_context3_no_force_deep_merge
      end
    end

    # Initialize a new configuration object with contextualized defaults from the
    # global configuration option collection (no hierarchical support).
    #
    describe "#init_flat" do

      it "creates with global contextual options only (multiple contexts)" do
        test_config Config.init_flat(nil, config_flat_contexts1, {}, true, true), config_flat_context_options1
      end
      it "creates with global contextual options only (single context)" do
        test_config Config.init_flat(nil, config_flat_contexts2, {}, true, true), config_flat_context_options2
      end
    end


    #***************************************************************************
    # Constructor / Destructor

    # Initialize a new Nucleon core object
    #
    describe "#initialize" do

      it "creates with default values if nil given as the primary data source" do
        test_config Config.new(nil, config_hash1, true, true), config_hash1
        test_config Config.new(nil, config_hash1, true, false), config_hash1
        test_config Config.new(nil, config_hash1, false, true), config_hash1
        test_config Config.new(nil, config_hash1, false, false), config_hash1
      end

      it "creates via a basic merge of hash with forced overwrites" do
        test_config Config.new(config_hash2, config_hash1, true, true), config_hash_force_basic_merge
      end
      it "creates via a deep merge of hash with forced overwrites" do
        test_config Config.new(config_hash2, config_hash1, true, false), config_hash_force_deep_merge
      end
      it "creates via a basic merge of hash with no forced overwrites" do
        test_config Config.new(config_hash2, config_hash1, false, true), config_hash_no_force_basic_merge
      end
      it "creates via a deep merge of hash with no forced overwrites" do
        test_config Config.new(config_hash2, config_hash1, false, false), config_hash_no_force_deep_merge
      end

      it "creates via a basic merge of Config object with forced overwrites" do
        test_config Config.new(config_object, config_hash1, true, true), config_hash_force_basic_merge
      end
      it "creates via a deep merge of Config object with forced overwrites" do
        test_config Config.new(config_object, config_hash1, true, false), config_hash_force_deep_merge
      end
      it "creates via a basic merge of Config object with no forced overwrites" do
        test_config Config.new(config_object, config_hash1, false, true), config_hash_no_force_basic_merge
      end
      it "creates via a deep merge of Config object with no forced overwrites" do
        test_config Config.new(config_object, config_hash1, false, false), config_hash_no_force_deep_merge
      end
    end


    #***************************************************************************
    # Checks

    # Check whether or not this configuration object is empty.
    #
    describe "#empty?" do

      it "returns false if properties are in the configuration object" do
        test_eq Config.new(config_hash1, {}, true, true).empty?, false
      end

      it "returns true if the configuration object is empty" do
        test_eq Config.new(nil, {}, true, true).empty?, true
      end
    end

    # Check whether or not this configuration object has a specific key.
    #
    describe "#has_key?" do

      it "is true if a top level key exists in the configuration object" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          test_eq config.has_key?("testkey"), true
          test_eq config.has_key?(:testkey), true
        end
      end
      it "is true if a nested key exists in the configuration object" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          test_eq config.has_key?([ "nestedkey", "a", "test1" ]), true
          test_eq config.has_key?([ :nestedkey, :a, :test1 ]), true
          test_eq config.has_key?([ "nestedkey", "a", :test1 ]), true
          test_eq config.has_key?([ :nestedkey, nil, :a, nil, :test1, nil ]), true
        end
      end

      it "is false if a top level key does not exist in the configuration object" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          test_eq config.has_key?("some_non_existent_key"), false
          test_eq config.has_key?(:some_non_existent_key), false
        end
      end
      it "is false if a nested key does not exist in the configuration object" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          test_eq config.has_key?([ "nestedkey", "test5" ]), false
          test_eq config.has_key?([ :nestedkey, :test5 ]), false
          test_eq config.has_key?([ "nestedkey", :test5 ]), false
          test_eq config.has_key?([ :nestedkey, nil, :test5, nil ]), false
        end
      end
    end


    #***************************************************************************
    # Property accessors / modifiers

    # Return all of the keys for the configuration properties hash.
    #
    describe "#keys" do

      it "returns the top level property keys in the configuration object" do
        test_eq Config.new(config_hash1, {}, true, true).keys, [ :testkey, :nestedkey, :other, :array ]
        test_eq Config.new(config_hash2, {}, true, true).keys, [ :testkey1, :nestedkey, :other, :array ]
      end
    end

    # Fetch value for key path in the configuration object.
    #
    describe "#get" do

      it "returns an existing value for a top level property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey, nil, false), 'testval'
        test_eq Config.new(config_hash2, {}, true, true).get(:testkey1, nil, false), 'testval1'
      end
      it "returns an existing value for a nested property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, :test2 ], nil, false), [ 'no' ]
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, nil, :y, nil ], nil, false), 'again'
        test_eq Config.new(config_hash2, {}, true, true).get([ :nestedkey, :a, :test1 ], nil, false), 'oh'
        test_eq Config.new(config_hash2, {}, true, true).get([ :nestedkey, :a, nil, :test3, nil ], nil, false), true
      end

      it "returns a default value for a top level property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, false, false), false
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, 'string', false), 'string'
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, :symbol, false), :symbol
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, [ :a, :b, :c ], false), [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, { :a => :b }, false), { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, false, :test), false
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, '42', :test), true
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, 'string', :string), 'string'
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, :string, :string), 'string'
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, :symbol, :symbol), :symbol
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, 'symbol', :symbol), :symbol
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, [ :a, :b, :c ], :array), [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, :a, :array), [ :a ]
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, { :a => :b }, :hash), { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true).get(:testkey15, nil, :hash), {}
      end
      it "returns a default value for a nested property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], false, false), false
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], 'string', false), 'string'
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :symbol, false), :symbol
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], [ :a, :b, :c ], false), [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], { :a => :b }, false), { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], false, :test), false
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], '42', :test), true
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], 'string', :string), 'string'
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :string, :string), 'string'
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :symbol, :symbol), :symbol
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], 'symbol', :symbol), :symbol
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], [ :a, :b, :c ], :array), [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], :a, :array), [ :a ]
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], { :a => :b }, :hash), { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true).get([ :nestedkey, :a, nil, :unknown ], nil, :hash), {}
      end
    end

    # Fetch value for key path in the configuration object.
    #
    describe "#[]" do

      it "returns an existing value for a top level property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true)[:testkey, nil, false], 'testval'
        test_eq Config.new(config_hash2, {}, true, true)[:testkey1, nil, false], 'testval1'
      end

      it "returns a default value for a top level property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, false, false], false
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, 'string', false], 'string'
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, :symbol, false], :symbol
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, [ :a, :b, :c ], false], [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, { :a => :b }, false], { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, false, :test], false
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, '42', :test], true
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, 'string', :string], 'string'
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, :string, :string], 'string'
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, :symbol, :symbol], :symbol
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, 'symbol', :symbol], :symbol
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, [ :a, :b, :c ], :array], [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, :a, :array], [ :a ]
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, { :a => :b }, :hash], { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true)[:testkey15, nil, :hash], {}
      end
    end

    # Fetch filtered array value for key path in the configuration object.
    #
    describe "#get_array" do

      it "returns an existing array for a top level property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true).get_array(:testkey, []), [ 'testval' ]
        test_eq Config.new(config_hash2, {}, true, true).get_array(:testkey1, []), [ 'testval1' ]
      end
      it "returns an existing array for a nested property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, :a, :test2 ], []), [ 'no' ]
        test_eq Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, nil, :y, nil ], []), [ 'again' ]
        test_eq Config.new(config_hash2, {}, true, true).get_array([ :nestedkey, :a, :test1 ], []), [ 'oh' ]
        test_eq Config.new(config_hash2, {}, true, true).get_array([ :nestedkey, :a, nil, :test3, nil ], []), [ true ]
      end

      it "returns a default array for a top level property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true).get_array(:testkey15, [ :a, :b, :c ]), [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true).get_array(:testkey15, :a), [ :a ]
      end
      it "returns a default array for a nested property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, :a, nil, :unknown ], [ :a, :b, :c ]), [ :a, :b, :c ]
        test_eq Config.new(config_hash1, {}, true, true).get_array([ :nestedkey, :a, nil, :unknown ], :a), [ :a ]
      end
    end

    # Fetch filtered hash value for key path in the configuration object.
    #
    describe "#get_hash" do

      it "returns an existing hash for a top level property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true).get_hash(:nestedkey, {}), {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'no' ]
          },
          :x => 'hello',
          :y => 'again',
          :z => 'im done now'
        }
        test_eq Config.new(config_hash2, {}, true, true).get_hash(:nestedkey, {}), {
          :a => {
            :test1 => 'oh',
            :test2 => [ 'yes' ],
            :test3 => true
          },
          :z => 'whew'
        }
      end
      it "returns an existing hash for a nested property from the configuration object if it exists" do
        test_eq Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, :a ], {}), { :test1 => 'oh', :test2 => [ 'no' ]  }
        test_eq Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, nil, :y, nil ], {}), {}
        test_eq Config.new(config_hash2, {}, true, true).get_hash([ :nestedkey, :a ], {}), { :test1 => 'oh', :test2 => [ 'yes' ], :test3 => true }
        test_eq Config.new(config_hash2, {}, true, true).get_hash([ :nestedkey, :a, nil, :test3, nil ], {}), {}
      end

      it "returns a default hash for a top level property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true).get_hash(:testkey15, { :a => :b }), { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true).get_hash(:testkey15, nil), {}
      end
      it "returns a default hash for a nested property from the configuration object if it does not exist" do
        test_eq Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, :a, nil, :unknown ], { :a => :b }), { :a => :b }
        test_eq Config.new(config_hash1, {}, true, true).get_hash([ :nestedkey, :a, nil, :unknown ], nil), {}
      end
    end

    # Initialize value for key path in the configuration object if one does not
    # exist yet.
    #
    describe "#init" do

      it "sets a top level configuration property that does not exist yet" do
        test_eq Config.new(config_hash1, {}, true, true).init(:other_property, 'testing').get(:other_property), 'testing'
        test_eq Config.new(config_hash2, {}, true, true).init(:new_property, 'testing2').get(:new_property), 'testing2'
      end
      it "sets a nested configuration property that does not exist yet" do
        test_eq Config.new(config_hash1, {}, true, true).init([ :nested_property, :abc ], [ 1, 2, 3 ]).get([ :nested_property, :abc ]), [ 1, 2, 3 ]
        test_eq Config.new(config_hash2, {}, true, true).init([ :nested_property, :abc ], [ 1, 2, 3 ]).get([ :nested_property, :abc ]), [ 1, 2, 3 ]
      end

      it "leaves a top level configuration property untouched if it already exists" do
        test_eq Config.new(config_hash1, {}, true, true).init(:other, 'testing').get(:other), [ 1, 2, 3, 4 ]
        test_eq Config.new(config_hash2, {}, true, true).init(:other, 'testing').get(:other), 56
      end
      it "leaves a nested configuration property untouched if it already exists" do
        test_eq Config.new(config_hash1, {}, true, true).init([ :nestedkey, :a ], { :a => :b }).get([ :nestedkey, :a ]), { :test1 => 'oh', :test2 => [ 'no' ] }
        test_eq Config.new(config_hash2, {}, true, true).init([ :nestedkey, :a ], { :a => :b }).get([ :nestedkey, :a ]), { :test1 => 'oh', :test2 => [ 'yes' ], :test3 => true }
      end
    end

    # Set value for key path in the configuration object.
    #
    describe "#set" do

      it "creates a configuration property with a specified value" do
        test_eq Config.new(config_hash1, {}, true, true).set("other_property", "onething", false).get(:other_property), 'onething'
        test_eq Config.new(config_hash2, {}, true, true).set(:other_property, { "a" => :b }, false).get([ :other_property, :a ]), :b
      end

      it "updates a configuration property with a specified value" do
        test_eq Config.new(config_hash1, {}, true, true).set("other", "onething", false).get(:other), 'onething'
        test_eq Config.new(config_hash2, {}, true, true).set(:nestedkey, { "a" => :b }, false).get([ :nestedkey, :a ]), :b
      end

      it "removes a configuration property containing a nil value" do
        test_eq Config.new(config_hash1, {}, true, true).set(:array, nil, true).keys, [ :testkey, :nestedkey, :other ]
        test_eq Config.new(config_hash2, {}, true, true).set(:array, nil, true).keys, [ :testkey1, :nestedkey, :other ]
      end
    end

    # Set value for key in the configuration object.
    #
    describe "#[]=" do

      it "creates a configuration property with a specified value" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          config["other_property"] = "onething"
          test_eq config.get(:other_property), 'onething'
        end

        test_object(Config, config_hash2, {}, true, true) do |config|
          config[:other_property] = { "a" => :b }
          test_eq config.get([ :other_property, :a ]), :b
        end
      end

      it "updates a configuration property with a specified value" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          config["other"] = "onething"
          test_eq config.get(:other), 'onething'
        end

        test_object(Config, config_hash2, {}, true, true) do |config|
          config[:nestedkey] = { "a" => :b }
          test_eq config.get([ :nestedkey, :a ]), :b
        end
      end
    end

    # Delete key path from the configuration object.
    #
    describe "#delete" do

      it "removes a configuration property and returns existing value" do
        test_object(Config, config_hash1, {}, true, true) do |config|
          test_eq config.delete(:other, nil), [ 1, 2, 3, 4 ]
          test_eq config.keys, [ :testkey, :nestedkey, :array ]
        end

        test_object(Config, config_hash2, {}, true, true) do |config|
          test_eq config.delete(:array, nil), [ 12 ]
          test_eq config.keys, [ :testkey1, :nestedkey, :other ]
        end
      end

      it "returns a default value if configuration property doesn't exist" do
        test_eq Config.new(config_hash1, {}, true, true).delete(:test57, :yummy), :yummy
        test_eq Config.new(config_hash2, {}, true, true).delete(:test57, [ 1, 2, 3 ]), [ 1, 2, 3 ]
      end
    end

    # Clear all properties from the configuration object.
    #
    describe "#clear" do

      it "removes all the configuration properties from the object" do
        test_config Config.new(config_hash1, {}, true, true).clear, {}
        test_config Config.new(config_hash2, {}, true, true).clear, {}
      end
    end


    #***************************************************************************
    # Import / Export

    # Import new property values into the configuration object. (override)
    #
    describe "#import" do

    # TODO: String and symbol lookup conditions (used in CORL)

      it "imports properties via a basic merge of hash with forced overwrites" do
        test_config Config.new({}, {}, true, true).import([ config_hash1, config_hash2 ]), config_hash_force_basic_merge
        test_config Config.new(config_hash1, {}, true, true).import(config_hash2), config_hash_force_basic_merge
        test_config Config.new(config_hash1, {}, false, false).import(config_hash2, { :force => true, :basic => true }), config_hash_force_basic_merge
      end
      it "imports properties via a deep merge of hash with forced overwrites" do
        test_config Config.new({}, {}, true, false).import([ config_hash1, config_hash2 ]), config_hash_force_deep_merge
        test_config Config.new(config_hash1, {}, true, false).import(config_hash2), config_hash_force_deep_merge
        test_config Config.new(config_hash1, {}, false, true).import(config_hash2, { :force => true, :basic => false }), config_hash_force_deep_merge
      end
      it "imports properties via a basic merge of hash with no forced overwrites" do
        test_config Config.new({}, {}, false, true).import([ config_hash1, config_hash2 ]), config_hash_no_force_basic_merge
        test_config Config.new(config_hash1, {}, false, true).import(config_hash2), config_hash_no_force_basic_merge
        test_config Config.new(config_hash1, {}, true, false).import(config_hash2, { :force => false, :basic => true }), config_hash_no_force_basic_merge
      end
      it "imports properties via a deep merge of hash with no forced overwrites" do
        test_config Config.new({}, {}, false, false).import([ config_hash1, config_hash2 ]), config_hash_no_force_deep_merge
        test_config Config.new(config_hash1, {}, false, false).import(config_hash2), config_hash_no_force_deep_merge
        test_config Config.new(config_hash1, {}, true, true).import(config_hash2, { :force => false, :basic => false }), config_hash_no_force_deep_merge
      end

      it "imports properties via a basic merge of Config object with forced overwrites" do
        test_config Config.new({}, {}, true, true).import([ config_hash1, config_object ]), config_hash_force_basic_merge
        test_config Config.new(config_hash1, {}, true, true).import(config_object), config_hash_force_basic_merge
        test_config Config.new(config_hash1, {}, false, false).import(config_object, { :force => true, :basic => true }), config_hash_force_basic_merge
      end
      it "imports properties via a deep merge of Config object with forced overwrites" do
        test_config Config.new({}, {}, true, false).import([ config_hash1, config_object ]), config_hash_force_deep_merge
        test_config Config.new(config_hash1, {}, true, false).import(config_object), config_hash_force_deep_merge
        test_config Config.new(config_hash1, {}, false, true).import(config_object, { :force => true, :basic => false }), config_hash_force_deep_merge
      end
      it "imports properties via a basic merge of Config object with no forced overwrites" do
        test_config Config.new({}, {}, false, true).import([ config_hash1, config_object ]), config_hash_no_force_basic_merge
        test_config Config.new(config_hash1, {}, false, true).import(config_object), config_hash_no_force_basic_merge
        test_config Config.new(config_hash1, {}, true, false).import(config_object, { :force => false, :basic => true }), config_hash_no_force_basic_merge
      end
      it "imports properties via a deep merge of Config object with no forced overwrites" do
        test_config Config.new({}, {}, false, false).import([ config_hash1, config_object ]), config_hash_no_force_deep_merge
        test_config Config.new(config_hash1, {}, false, false).import(config_object), config_hash_no_force_deep_merge
        test_config Config.new(config_hash1, {}, true, true).import(config_object, { :force => false, :basic => false }), config_hash_no_force_deep_merge
      end
    end

    # Set default property values in the configuration object if they don't exist.
    #
    describe "#defaults" do

    # TODO: String and symbol lookup conditions (used in CORL)

      it "imports default properties via a basic merge of hash with forced overwrites" do
        test_config Config.new({}, {}, true, true).defaults([ config_hash2, config_hash1 ]), config_hash_force_basic_merge
        test_config Config.new(config_hash2, {}, true, true).defaults(config_hash1), config_hash_force_basic_merge
        test_config Config.new(config_hash2, {}, false, false).defaults(config_hash1, { :force => true, :basic => true }), config_hash_force_basic_merge
      end
      it "imports default properties via a deep merge of hash with forced overwrites" do
        test_config Config.new({}, {}, true, false).defaults([ config_hash2, config_hash1 ]), config_hash_force_deep_merge
        test_config Config.new(config_hash2, {}, true, false).defaults(config_hash1), config_hash_force_deep_merge
        test_config Config.new(config_hash2, {}, false, true).defaults(config_hash1, { :force => true, :basic => false }), config_hash_force_deep_merge
      end
      it "imports default properties via a basic merge of hash with no forced overwrites" do
        test_config Config.new({}, {}, false, true).defaults([ config_hash2, config_hash1 ]), config_hash_no_force_basic_merge
        test_config Config.new(config_hash2, {}, false, true).defaults(config_hash1), config_hash_no_force_basic_merge
        test_config Config.new(config_hash2, {}, true, false).defaults(config_hash1, { :force => false, :basic => true }), config_hash_no_force_basic_merge
      end
      it "imports default properties via a deep merge of hash with no forced overwrites" do
        test_config Config.new({}, {}, false, false).defaults([ config_hash2, config_hash1 ]), config_hash_no_force_deep_merge
        test_config Config.new(config_hash2, {}, false, false).defaults(config_hash1), config_hash_no_force_deep_merge
        test_config Config.new(config_hash2, {}, true, true).defaults(config_hash1, { :force => false, :basic => false }), config_hash_no_force_deep_merge
      end

      it "imports default properties via a basic merge of Config object with forced overwrites" do
        test_config Config.new({}, {}, true, true).defaults([ config_object, config_hash1 ]), config_hash_force_basic_merge
        test_config Config.new(config_object, {}, true, true).defaults(config_hash1), config_hash_force_basic_merge
        test_config Config.new(config_object, {}, false, false).defaults(config_hash1, { :force => true, :basic => true }), config_hash_force_basic_merge
      end
      it "imports default properties via a deep merge of Config object with forced overwrites" do
        test_config Config.new({}, {}, true, false).defaults([ config_object, config_hash1 ]), config_hash_force_deep_merge
        test_config Config.new(config_object, {}, true, false).defaults(config_hash1), config_hash_force_deep_merge
        test_config Config.new(config_object, {}, false, true).defaults(config_hash1, { :force => true, :basic => false }), config_hash_force_deep_merge
      end
      it "imports default properties via a basic merge of Config object with no forced overwrites" do
        test_config Config.new({}, {}, false, true).defaults([ config_object, config_hash1 ]), config_hash_no_force_basic_merge
        test_config Config.new(config_object, {}, false, true).defaults(config_hash1), config_hash_no_force_basic_merge
        test_config Config.new(config_object, {}, true, false).defaults(config_hash1, { :force => false, :basic => true }), config_hash_no_force_basic_merge
      end
      it "imports default properties via a deep merge of Config object with no forced overwrites" do
        test_config Config.new({}, {}, false, false).defaults([ config_object, config_hash1 ]), config_hash_no_force_deep_merge
        test_config Config.new(config_object, {}, false, false).defaults(config_hash1), config_hash_no_force_deep_merge
        test_config Config.new(config_object, {}, true, true).defaults(config_hash1, { :force => false, :basic => false }), config_hash_no_force_deep_merge
      end
    end

    # Export properties into a regular hash object (cloned)
    #
    describe "#export" do

      it "returns all configuration properties as a symbolized hash" do
        test_config Config.new(config_hash1, {}, true, true), config_hash1
        test_config Config.new(config_hash2, {}, true, true), config_hash2
      end
    end


    #***************************************************************************
    # Utilities

    # Return hash as a symbol map.
    #
    describe "#symbol_map" do

      it "returns a hash with recursively symbolized keys" do
        test_eq Config.symbol_map(config_mixed_hash), config_symbolized_hash
      end
    end

    # Return hash as a string map.
    #
    describe "#string_map" do

      it "returns a hash with recursively stringified keys" do
        test_eq Config.string_map(config_mixed_hash), config_stringified_hash
      end
    end


    #***************************************************************************

    # Run a defined filter on a data object.
    #
    describe "#filter" do

      it "returns given value when not filtered" do
        test_eq Config.filter(true, false), true
        test_eq Config.filter("string", false), "string"
        test_eq Config.filter(:symbol, false), :symbol
        test_eq Config.filter([ "test", "array" ], false), [ "test", "array" ]
        test_eq Config.filter({ :a => :b }, false), { :a => :b }
      end
      it "returns a boolean when filtered for a test condition" do
        test_eq Config.filter(2 == 2, :test), true
        test_eq Config.filter(2 == 5, :test), false
        test_eq Config.filter("hello", :test), true
        test_eq Config.filter([ '1' ], :test), true
        test_eq Config.filter([], :test), false
        test_eq Config.filter({ "a" => "b" }, :test), true
        test_eq Config.filter({}, :test), false
      end
      it "returns a string when filtered for a string" do
        test_eq Config.filter("string", :string), "string"
        test_eq Config.filter(:symbol, :string), "symbol"
        test_eq Config.filter(true, :string), "true"
        test_eq Config.filter([ 1, 2, 3 ], :string), "[1, 2, 3]"
        test_eq Config.filter({ :a => :b }, :string), "{:a=>:b}"
      end
      it "returns a symbol when filtered for a symbol" do
        test_eq Config.filter("string", :symbol), :string
        test_eq Config.filter(:symbol, :symbol), :symbol
        test_eq Config.filter(true, :symbol), :true
      end
      it "returns an array when filtered for a array" do
        test_eq Config.filter(nil, :array), []
        test_eq Config.filter("test", :array), [ "test" ]
        test_eq Config.filter([ "test", "array" ], :array), [ "test", "array" ]
      end
      it "returns a hash when filtered for a hash" do
        test_eq Config.filter(nil, :hash), {}
        test_eq Config.filter("test", :hash), {}
        test_eq Config.filter({ :a => :b }, :hash), { :a => :b }
      end
    end


    #***************************************************************************

    # Ensure a data object is an array.
    #
    describe "#array" do

      it "returns a filtered array" do
        test_eq Config.filter(nil, :array), []
        test_eq Config.filter("test", :array), [ "test" ]
        test_eq Config.filter([ "test", "array" ], :array), [ "test", "array" ]
      end
    end

    # Ensure a data object is a hash.
    #
    describe "#hash" do

      it "returns a filtered hash" do
        test_eq Config.filter(nil, :hash), {}
        test_eq Config.filter("test", :hash), {}
        test_eq Config.filter({ :a => :b }, :hash), { :a => :b }
      end
    end

    # Ensure a data object is a string.
    #
    describe "#string" do

      it "returns a filtered string" do
        test_eq Config.filter("string", :string), "string"
        test_eq Config.filter(:symbol, :string), "symbol"
        test_eq Config.filter(true, :string), "true"
        test_eq Config.filter([ 1, 2, 3 ], :string), "[1, 2, 3]"
        test_eq Config.filter({ :a => :b }, :string), "{:a=>:b}"
      end
    end

    # Ensure a data object is a symbol.
    #
    describe "#symbol" do

      it "returns a filtered symbol" do
        test_eq Config.filter("string", :symbol), :string
        test_eq Config.filter(:symbol, :symbol), :symbol
        test_eq Config.filter(true, :symbol), :true
      end
    end

    # Test a data object for emptiness and return boolean result.
    #
    describe "#test" do

      it "returns a filtered boolean" do
        test_eq Config.filter(2 == 2, :test), true
        test_eq Config.filter(2 == 5, :test), false
        test_eq Config.filter("hello", :test), true
        test_eq Config.filter([ '1' ], :test), true
        test_eq Config.filter([], :test), false
        test_eq Config.filter({ "a" => "b" }, :test), true
        test_eq Config.filter({}, :test), false
      end
    end
  end
end