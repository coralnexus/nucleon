require 'spec_helper'

module Nucleon
  describe Config do
    
    let(:testhash1) { {:abc => '1'} }
    let(:testhash2) { {:xyz => '2'} }
    let(:testhash3) { {:abc => 1} }
    let(:testhash4) { {:abc => 1, :def => 2} }
    let(:testhash5) { { :my_property => 'default', :other_property => 'default' } }
    let(:testhash6) { { :other_property => 'something' } }
    let(:testhash7) { {:my_property => 'default'} }
    let(:testhash8) { {:my_property => 'default', :other_property => 'something'} }
    let(:testhash9) { { :other_property => 'something', :someother_property => 'someonemore'} }
    let(:testhash10) { {:my_property => 'default', :other_property => 'anything'} }
    let(:testhash11) { {:testkey => 'test value'} }
    
    let(:test_output_hash1) { {:abc=>"1"} }
    let(:test_output_hash2) { {:abc=>"1", :xyz=>"2"} }
    
    let(:test_array_1) { ["abc","def"] }
    let(:test_array_2) { ["uvw","xyz"] }
    let(:test_array_3) { ["test1","test2"] }
    let(:test_array_4) { ["string1","string2"] }
    
    let(:test_array_sym_1) { [:abc, :def] }
    let(:test_array_sym_2) { [:uvw, :xyz] }
    let(:test_array_sym_3) { [:symbol1,:symbol2] }
    
    
    let(:testobj) { Config.new() }
           
    #*****************************************************************************
    # Instance generators
    
    # Ensure the return of a Nucleon::Config object based on different inputs.
    #
    describe "#ensure" do
      
      it "tests return type as configuration object on passing nil config param to ensure" do
        
        expect(Config.ensure(nil, testhash1, true, true)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(nil, testhash1, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(nil, testhash1, false, true)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(nil, testhash1, false, false)).to be_kind_of(Nucleon::Config)
        
      end
      
      it "tests return value  on passing nil config param to ensure" do
        
        expect(Config.ensure(nil, testhash1, true, true).export).to eq(test_output_hash1)
        expect(Config.ensure(nil, testhash1, true, false).export).to eq(test_output_hash1)
        expect(Config.ensure(nil, testhash1, false, true).export).to eq(test_output_hash1)
        expect(Config.ensure(nil, testhash1, false, false).export).to eq(test_output_hash1)
        
      end
      
      it "tests return type as configuration object on passing Hash config param to ensure" do
        
        expect(Config.ensure(testhash2, testhash1, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(testhash2, testhash1, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(testhash2, testhash1, false, true)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(testhash2, testhash1, false, false)).to be_kind_of(Nucleon::Config)
        
      end
      
       it "tests return value on passing Hash config param to ensure" do
        
        expect(Config.ensure(testhash2, testhash1, true, false).export).to eq(test_output_hash2)
        expect(Config.ensure(testhash2, testhash1, true, false).export).to eq(test_output_hash2)
        expect(Config.ensure(testhash2, testhash1, false, true).export).to eq(test_output_hash2)
        expect(Config.ensure(testhash2, testhash1, false, false).export).to eq(test_output_hash2)
        
      end
      
      it "tests return value as configuration object on passing Nucleon::Config config param to ensure" do
        
        
        expect(Config.ensure(testobj, testhash1, false, true)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(testobj, testhash1, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(testobj, testhash1, false, true)).to be_kind_of(Nucleon::Config)
        expect(Config.ensure(testobj, testhash1, false, false)).to be_kind_of(Nucleon::Config)
        
      end
      
      it "tests return value as configuration object on passing Nucleon::Config config param to ensure" do
         
        expect(Config.ensure(testobj, testhash1, false, true).export).to eq(test_output_hash1)
        expect(Config.ensure(testobj, testhash1, true, false).export).to eq(test_output_hash1)
        expect(Config.ensure(testobj, testhash1, false, true).export).to eq(test_output_hash1)
        expect(Config.ensure(testobj, testhash1, false, false).export).to eq(test_output_hash1)
        
      end              
    end
    
    # Initialize a new configuration object with contextualized defaults from the
    # global configuration option collection.
  
    describe "#init" do
        
      it "tests params as nil, hash and Nucleon::Config for options with init" do
        
        expect(Config.init(nil, test_array_1, test_array_2, testhash3, true, true)).to be_kind_of(Nucleon::Config)
        expect(Config.init({:xyz => 5}, test_array_1, test_array_2, testhash3, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.init(testobj, test_array_1, test_array_2, testhash3, false, false)).to be_kind_of(Nucleon::Config)
        
      end
      
      #**************
      #Validates the return type is a configuration object of type Nucleon::Config
      
      it "tests params as array of string and symbols for contexts with init" do
        
        expect(Config.init(nil, test_array_1, test_array_2, testhash3, true, true)).to be_kind_of(Nucleon::Config)
        expect(Config.init(testobj, test_array_sym_1, test_array_2, testhash3, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.init(nil, "abc", test_array_2, testhash3, true, true)).to be_kind_of(Nucleon::Config)
        
      end
      
      #**************
      #Validates the return type is a configuration object of type Nucleon::Config
      
      it "tests params as array of string and symbols for hierarchy with init" do
        
        expect(Config.init(nil, test_array_1, test_array_2, testhash3, true, true).instance_of? Nucleon::Config).to eq true
        expect(Config.init(testobj, test_array_sym_1, test_array_sym_2, testhash3, true, false).instance_of? Nucleon::Config).to eq true
        
      end
      
    end
    
    
    # Initialize a new configuration object with contextualized defaults from the
    # global configuration option collection (no hierarchical support).
    #
    
    describe "#init_flat" do
      
      it "tests nil, Hash, Nucleon::Config  options param value with init_flat" do
        
        expect(Config.init_flat(nil, test_array_3, testhash4, true, true)).to be_kind_of(Nucleon::Config)
        expect(Config.init_flat({:xyz => '1'}, test_array_3, testhash4, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.init_flat(testobj, test_array_3, testhash4, false, true)).to be_kind_of(Nucleon::Config)
        
      end
      
      it "tests return val for nil, Hash, Nucleon::Config  options param value with init_flat" do
        
        expect(Config.init_flat(nil, test_array_3, testhash4, true, true).export).to eq testhash4
        expect(Config.init_flat({:xyz => '1'}, test_array_3, testhash4, true, false).export).to eq({:abc=>1, :def=>2, :xyz=>"1"})
        expect(Config.init_flat(testobj, test_array_3, testhash4, false, true).export).to eq testhash4
        
      end
      
      it "tests params as array of string and symbols for contexts with init_flat" do
        
        expect(Config.init_flat(nil, test_array_4, testhash4, true, true)).to be_kind_of(Nucleon::Config)
        expect(Config.init_flat(nil, test_array_sym_3, testhash4, false, false)).to be_kind_of(Nucleon::Config)
        
      end
      
      it "tests return val for params as array of string and symbols for contexts with init_flat" do
        
        expect(Config.init_flat(nil, test_array_4, testhash4, true, true).export).to eq testhash4
        expect(Config.init_flat(nil, test_array_sym_3, testhash4, false, false).export).to eq testhash4
        
      end
    end
    
    
  #*****************************************************************************
  # Constructor / Destructor
  
    describe "#initialize" do
          
      it "tests nil, Hash and Nucleon::Config param value for data with initialize" do
        
        expect(Config.new(nil, testhash5, true, true)).to be_kind_of(Nucleon::Config)
        expect(Config.new(testhash6,testhash5, true, false)).to be_kind_of(Nucleon::Config)
        expect(Config.new(testobj,testhash5, false, false)).to be_kind_of(Nucleon::Config)
        
      end
      
      it "tests return val on hash merge with initialize" do
        
        expect(Config.new(testhash6,testhash5, true, false).export).to eq({:my_property=>"default", :other_property=>"something"})
        
      end
      
    end
 
  #*****************************************************************************
  # Checks
  
   describe "#empty?" do

     it "tests true and false returns value with empty?" do
       
       expect(Config.new(testhash6,testhash5, true, true).empty?).to eq false
       expect(Config.new(nil,testhash5, true, true).empty?).to eq true
       
     end
     
   end
   
  # Check whether or not this configuration object has a specific key.
  #
     
   describe "#has_key?" do
     
     it "tests true and false return values with has_key?" do
       
       expect(Config.new(testhash6,testhash5, true, true).has_key?("other_property")).to eq true
       expect(Config.new(testhash6,testhash5, true, true).has_key?(:other_property)).to eq true
       expect(Config.new(testhash6,testhash5, true, true).has_key?(:another_property)).to eq false
       expect(Config.new(nil,testhash5, true, true).has_key?("another_property")).to eq false
       
     end
   end
   
  #*****************************************************************************
  # Property accessors / modifiers
  
  # Return all of the keys for the configuration properties hash.

  describe "#keys" do
    
    
    it "tests an array is returned using keys" do
      
      expect(Config.new(testhash6,testhash7, true, true).keys.is_a?(Array)).to eq true
      
    end
    
    it "tests an array with keys is returned using keys" do
      
      expect(Config.new(testhash6,testhash8, true, true).keys).to eq [:my_property,:other_property]
      
    end
    
  end
  
  

 
  
  # Fetch value for key path in the configuration object.
  #
    
  describe "#get" do
    
    it "tests returned value by passing a string to get" do
      
      expect(Config.new(testhash9,testhash7, true, true).get("someother_property",nil,false)).to eq "someonemore" 
      
    end
    
    it "tests returned value by passing a symbol to get" do
      
      expect(Config.new(testhash9,testhash7, true, true).get(:other_property,nil,false)).to eq "something" 
      
    end
  end
  
  # Fetch value for key path in the configuration object.
  #
  
  describe "#[]" do
    
    it "tests returned value by passing a string to []" do
      
      expect(Config.new(testhash9,testhash7, true, true).[]("my_property",nil,false)).to eq "default"
      
    end
    
    it "tests returned value by passing a symbol to []" do
      
      expect(Config.new(testhash9,testhash7, true, true).[](:other_property,nil,false)).to eq "something"
      
    end
    
  end
  
  # Fetch filtered array value for key path in the configuration object.
  #

  describe "#get_array" do
    
    it "tests return type by passing a string to get_array" do
      
      expect(Config.new(testhash9,testhash10, true, true).get_array("other_property",nil)).to be_kind_of(Array)

    end
    
    it "tests return value of get_array" do
      
      expect(Config.new(testhash9,testhash10, true, true).get_array("other_property",nil)).to eq ["something"]
      
    end
    
    it "tests return type by passing a symbol to get_array" do
      
      expect(Config.new(testhash9,testhash10, true, true).get_array(:someother_property,nil)).to be_kind_of(Array)
      
    end
    
  end
  
  # Fetch filtered hash value for key path in the configuration object.
  #
  
  describe "#get_hash" do
    
    it "tests return type by passing a string to get_hash" do
      
      expect(Config.new(testhash9,testhash7, true, true).get_hash("other_property",nil)).to be_kind_of(Hash)
    end
    
    
    it "tests return value of get_hash" do
      
      expect(Config.new({ :other_property => testhash11, :someother_property => 'someonemore'},testhash7, true, true).get_hash("other_property",nil)).to eq testhash11
      
    end
    
    it "tests return type by passing a symbol to get_hash" do
      
      expect(Config.new(testhash9,testhash7, true, true).get_hash(:someother_property,nil)).to be_kind_of(Hash)
      
    end
  end
  
  # Initialize value for key path in the configuration object if one does not
  # exist yet.
  
  describe "#init" do
    
    it "tests return type on sending symbol to init" do
      
      expect(Config.new(testhash9,testhash7, true, true).init(:other_property,nil)).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending string to init" do
      
      expect(Config.new(testhash9,testhash7, true, true).init("someother_property",nil)).to be_kind_of(Nucleon::Config)
      
    end
    
  end
  
  # Set value for key path in the configuration object.
  #
  
  describe "#set" do
    
    it "tests return type on sending string to set" do
      
      expect(Config.new(testhash9,testhash7, true, true).set("other_property","onething",nil)).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return value with set" do
      
      expect(Config.new(testhash9,testhash7, true, true).set("other_property","onething",nil).export).to eq({:my_property=>"default", :other_property=>"onething", :someother_property=>"someonemore"})
      
    end
    
    it "tests return type on sending symbol to set" do
      
      expect(Config.new(testhash9,testhash7, true, true).set(:someother_property,"onething",nil)).to be_kind_of(Nucleon::Config)
      
    end
    
  end
  
  # Set value for key in the configuration object.
  #
  
  describe "#[]=" do
    
    it "tests return type on sending string to []=" do
      
      expect(Config.new(testhash9,testhash7, true, true).[]=("other_property","newthing")).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending symbol to []=" do
      
      expect(Config.new(testhash9,testhash7, true, true).[]=(:someother_property,"newthing")).to be_kind_of(Nucleon::Config)
      
    end
    
  end
  
  # Delete key path from the configuration object.
  #
  
  describe "#delete" do
    
    it "tests return value on sending existing string key to delete" do
      
      expect(Config.new(testhash9,testhash7, true, true).delete("other_property",nil)).to eq "something"
      
    end
    
    it "tests return value on sending existing symbol key to delete" do
      
      expect(Config.new(testhash9,testhash7, true, true).delete(:someother_property,nil)).to eq "someonemore"
      
    end
    
    it "tests return value on sending non existing key to delete" do
      
      expect(Config.new(testhash9,testhash7, true, true).delete("notexists",nil)).to eq nil
      
    end
    
  end
  
  # Clear all properties from the configuration object.
  #
  
  describe "#clear" do
    
    it "tests return type of clear" do
      
      expect(Config.new(testhash9,testhash7, true, true).clear).to be_kind_of(Nucleon::Config)
      
      
    end
    
    it "tests return value of clear" do
      
      expect(Config.new(testhash9,testhash7, true, true).clear.export).to eq({})
      
    end
    
  end
  
  #*****************************************************************************
  # Import / Export

  # Import new property values into the configuration object. (override)
  #
  
  describe "#import" do
    
    it "tests return type on sending existing key as string to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import("other_property",{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return value on sending existing key as string to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import("other_property",{:force => @force}).export).to eq({:my_property=>"default", :other_property=>"something", :someother_property=>"someonemore"})
      
    end
    
    it "tests return type on sending existing key as symbol to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import(:someother_property,{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending non existing key as string to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import("notavail",{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending non existing key as symbol to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import(:notavail,{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending hash to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import({:other_property => 'something', :nothing => 'nomore'},{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending array of symbols to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import([:other_property, :nothing],{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending array of strings to import" do
      
      expect(Config.new(testhash9,testhash7, true, true).import(["other_property", "nothing"],{})).to be_kind_of(Nucleon::Config)
      
    end
    
  end  
  
  # Set default property values in the configuration object if they don't exist.
  #
  
  describe "#defaults" do
    
    it "tests return type on sending defaults value as a string to defaults" do
      
      expect(Config.new(testhash9,testhash7, true, true).defaults("defaultname",{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending defaults value as a symbol to defaults" do
      
      expect(Config.new(testhash9,testhash7, true, true).defaults(:defaultname,{})).to be_kind_of(Nucleon::Config)
      
    end
    
    it "tests return type on sending defaults value as a array to defaults" do
      
      expect(Config.new(testhash9,testhash7, true, true).defaults(["defaultname"],{})).to be_kind_of(Nucleon::Config)
      
      
    end
    
    it "tests return value on sending defaults value as a array to defaults" do
      
      expect(Config.new(testhash9,testhash7, true, true).defaults([{:defaultname => 'defaultval'}],{}).export).to eq({:defaultname=>"defaultval", :my_property=>"default", :other_property=>"something", :someother_property=>"someonemore"})
      
    end
    
    it "tests return value on sending defaults value as a hash to defaults" do
      
      expect(Config.new(testhash9,testhash7, true, true).defaults({:defaultkey => 'defaultvalue'},{})).to be_kind_of(Nucleon::Config)
      
    end
    
  end
  
  # Export properties into a regular hash object (cloned)
  #
  
  describe "#export" do
    
    it "tests return type with export" do
      
      expect(Config.new(testhash9,{:my_property => 'default', :someother_property => 'nothing'}, true, true).export).to be_kind_of(Hash)
      
    end
  end
  
  #*****************************************************************************
  # Utilities
  
  # Return hash as a symbol map.
  #
  
  describe "#symbol_map" do
    
    it "tests return type of symbol_map" do
      
      expect(Config.symbol_map(testhash11)).to be_kind_of(Hash)
      
    end
    
  end
  
  # Return hash as a string map.
  #
  
  describe "#string_map" do
    
    it "tests return type of string_map" do
      
      expect(Config.string_map(testhash11)).to be_kind_of(Hash)
      
    end
    
  end
  
  #*****************************************************************************

  # Run a defined filter on a data object.
  #
  
  describe "#filter" do
    
    it "tests return type on sending an array to filter" do
      
      expect(Config.filter(["test array"],false)).to be_kind_of(Array)
      
    end
    
    it "tests return type on sending a hash to filter" do
      
      expect(Config.filter(testhash11,false)).to be_kind_of(Hash)
      
    end
    
    it "tests return type on sending a string to filter" do
      
      expect(Config.filter("teststring",false)).to be_kind_of(String)
      
    end
    
    it "tests return type on sending a symbol to filter" do
      
      expect(Config.filter(:testsym,false)).to be_kind_of(Symbol)
      
    end
    
  end  
  
  #*****************************************************************************

  # Ensure a data object is an array.
  #
  
  describe "#array" do
  
    it "tests return type of array" do
      
      expect(Config.array("teststring",[],false)).to be_kind_of(Array)
      
    end
    
  end
  
  # Ensure a data object is a hash.
  #
  
  describe "#hash" do
    
    it "tests return type of hash" do
      
      expect(Config.hash(testhash11,{})).to be_kind_of(Hash)
      
    end
    
  end
  
  # Ensure a data object is a string.
  #
  
  describe "#string" do
    
    it "tests return type of string" do
      
      expect(Config.string(["test"],'')).to be_kind_of(String)
      
    end
 
  end
  
  # Ensure a data object is a symbol.
  #
    
  describe "#symbol" do
    
    it "tests return type of symbol" do
      
      expect(Config.symbol("Test", :undefined)).to be_kind_of(Symbol)
      
    end
    
  end
  
  # Test a data object for emptiness and return boolean result.
  #
  
  describe "#test" do
    
    it "tests return type as true for test" do
      
      expect(Config.test("testval")).to eq true
      
    end
    
    it "tests return type as false for test" do
      
      expect(Config.test("")).to eq false
      
    end
    
  end
  
 end
end