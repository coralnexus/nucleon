require 'spec_helper'

module Nucleon
  
  describe Core do
    
    let(:test_hash1) { {:testkey => 'testval'} }
    let(:test_hash2) { {:testkey1 => 'testval1'} }
    let(:merge_hash) { {:testkey=>"testval", :testkey1=>"testval1"} }
    
    let(:testobj) { Core.new }
    
    #*****************************************************************************
    # Constructor / Destructor
    
    # Initialize a new core Nucleon object
    #
    
    describe "#initialize" do
      
      it "tests nil data param for return type with initialize" do
          
        expect(Core.new(nil,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,true,true,false)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,true,false,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,true,false,false)).to be_kind_of(Nucleon::Core)
  
        expect(Core.new(nil,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,true,true,false)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,false,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,false,true,false)).to be_kind_of(Nucleon::Core)
        
        expect(Core.new(nil,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,true,false,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,false,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(nil,test_hash1,false,false,true)).to be_kind_of(Nucleon::Core)

        
      end
      
      #BUG :: Returns nil hash even basic_merge param is set to true
      #
      it "tests nil data param for return value with initialize" do
          
        expect(Core.new(nil,test_hash1,true,true,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,true,true,false).export).to eq({})
        expect(Core.new(nil,test_hash1,true,false,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,true,false,false).export).to eq({})
  
        expect(Core.new(nil,test_hash1,true,true,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,true,true,false).export).to eq({})
        expect(Core.new(nil,test_hash1,false,true,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,false,true,false).export).to eq({})
        
        expect(Core.new(nil,test_hash1,true,true,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,true,false,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,false,true,true).export).to eq(test_hash1)
        expect(Core.new(nil,test_hash1,false,false,true).export).to eq(test_hash1)

        
      end
      
      it "tests Hash data param for return type with initialize" do
          
        expect(Core.new(test_hash2,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,true,true,false)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,true,false,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,true,false,false)).to be_kind_of(Nucleon::Core)
  
        expect(Core.new(test_hash2,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,true,true,false)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,false,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,false,true,false)).to be_kind_of(Nucleon::Core)
        
        expect(Core.new(test_hash2,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,true,false,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,false,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(test_hash2,test_hash1,false,false,true)).to be_kind_of(Nucleon::Core)

        
      end
      
      # BUG :: Should not return a value, but returns merge of test_hash2,test_hash1. Returning the merge hase even after basic_merge is set to false  
      #
      it "tests Hash data param for return value with initialize" do
        
        expect(Core.new(test_hash2,test_hash1,true,true,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,true,true,false).export).to eq(test_hash2)
        expect(Core.new(test_hash2,test_hash1,true,false,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,true,false,false).export).to eq(test_hash2)
  
        expect(Core.new(test_hash2,test_hash1,true,true,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,true,true,false).export).to eq(test_hash2)
        expect(Core.new(test_hash2,test_hash1,false,true,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,false,true,false).export).to eq(test_hash2)
        
        expect(Core.new(test_hash2,test_hash1,true,true,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,true,false,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,false,true,true).export).to eq(merge_hash)
        expect(Core.new(test_hash2,test_hash1,false,false,true).export).to eq(merge_hash)

        
      end
      
      it "tests Core Object data param for return type with initialize" do
          
        expect(Core.new(testobj,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,true,true,false)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,true,false,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,true,false,false)).to be_kind_of(Nucleon::Core)
  
        expect(Core.new(testobj,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,true,true,false)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,false,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,false,true,false)).to be_kind_of(Nucleon::Core)
        
        expect(Core.new(testobj,test_hash1,true,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,true,false,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,false,true,true)).to be_kind_of(Nucleon::Core)
        expect(Core.new(testobj,test_hash1,false,false,true)).to be_kind_of(Nucleon::Core)

        
      end
      
      # Should not return a value, but returns merge of test_hash2,test_hash1 
      #
      it "tests Core Object data param for return value with initialize" do
     
        expect(Core.new(testobj,test_hash1,true,true,true).export).to eq(test_hash1)
        expect(Core.new(testobj,test_hash1,true,true,false).export).to eq(test_hash1)
        expect(Core.new(testobj,test_hash1,true,false,true).export).to eq({})
        expect(Core.new(testobj,test_hash1,true,false,false).export).to eq({})
  
        expect(Core.new(testobj,test_hash1,true,true,true).export).to eq({})
        expect(Core.new(testobj,test_hash1,true,true,false).export).to eq({})
        expect(Core.new(testobj,test_hash1,false,true,true).export).to eq({})
        expect(Core.new(testobj,test_hash1,false,true,false).export).to eq({})
        
        expect(Core.new(testobj,test_hash1,true,true,true).export).to eq({})
        expect(Core.new(testobj,test_hash1,true,false,true).export).to eq({})
        expect(Core.new(testobj,test_hash1,false,true,true).export).to eq({})
        expect(Core.new(testobj,test_hash1,false,false,true).export).to eq({})

        
      end
      
    end
    
    #*****************************************************************************
    # Checks
    
    # Check if object is initialized?
    #
    
    describe "#initialized?" do
      
      #BUG :: returns nil even set_initialized is set to false 
      #
      it "tests true and false return value with initialized?" do

        expect(Core.new(test_hash2,test_hash1,true,true,true).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,true,true,false).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,true,false,true).initialized?).to eq false
        expect(Core.new(test_hash2,test_hash1,true,false,false).initialized?).to eq false
  
        expect(Core.new(test_hash2,test_hash1,true,true,true).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,true,true,false).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,false,true,true).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,false,true,false).initialized?).to eq true
        
        expect(Core.new(test_hash2,test_hash1,true,true,true).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,true,false,true).initialized?).to eq false
        expect(Core.new(test_hash2,test_hash1,false,true,true).initialized?).to eq true
        expect(Core.new(test_hash2,test_hash1,false,false,true).initialized?).to eq false
        
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
        
        expect(Core.new(test_hash2,test_hash1,true,true,true).logger=Core.logger).to be_kind_of(Nucleon::Util::Logger)
        
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
        
        something = Core.new(test_hash2,test_hash1,true,true,true)
        something.ui = { :resource => "Testing", :color => true, :printer => :print }
        something.ui.info("This is Test Info")
        something.ui.success("This is Test Success")
        expect(Core.new(test_hash2,test_hash1,true,true,true).ui = Core.ui).to be_kind_of(Nucleon::Util::Console)
        
      end
      
    end
    
    #*****************************************************************************
    # General utilities
    
    # Contextualize console operations in a code block with a given resource name.
    #
    
    describe "#ui_group" do
      
      it "tests console output with ui_group" do
        
        output  = double('output')
        #output.should_receive(:puts).with(/^\[\e\[36mTest String\e\[0m\] -----------------------------------------------------$/)
        expect(output).to receive(:puts).with(/^\[\e\[36mTest String\e\[0m\] -----------------------------------------------------$/)
        
        Core.ui_group("Test String",:cyan) do |ui|
          ui.output = output
          ui.info("-----------------------------------------------------")
        end
        
      end
      
    end
    
  end
  
end