require 'spec_helper'

module Nucleon
  describe Codes do
    
    include_context "nucleon_test"
    include_context "nucleon_config"
    
    #-----------------------------------------------------------------------------
    # Code index
    
    describe "#registry" do
      
      it "tests return value is hash using registry" do
        
        test_type Codes.registry, Hash
      end
      
    end
    
    describe "#status_index" do
      
      it "tests return value is hash using status_index" do
        
        test_type Codes.status_index, Hash
      end
    end
    
    #---
  
    describe "#index" do
      it "testing nil parameter with index" do
        
         test_type Codes.index(nil), Hash
         
      end
      
      it "testing known status code with index" do  
        
        test_eq Codes.index(0), "success"
      end
      
      it "testing unknown status code with index" do
        
        test_eq Codes.index(100), "unknown_status"
      end
    end
    
    #---
  
    describe "#render_index" do
      it "testing with known status code parameter with render_index" do
        for i in 0 .. 6
          
          flag = Codes.render_index(i).include? "[   #{i} ]"
          test_eq flag, true
        end
      end
      
      it "testing with unknown status code parameter with render_index" do
          expect(Codes.render_index(100).include? "[   100 ]").to eq false
          flag = Codes.render_index(100).include? "[   100 ]"
          test_eq flag, false
      end
    end
    
  #-----------------------------------------------------------------------------
  # Code construction
  
    describe "#code" do
      it "testing nil return value on sending available key to code" do
        
        test_eq Codes.code("success"), nil
      end
      
      it "testing return value on sending unavailable key to code" do
        
        test_eq Codes.code("test1"), "test1"
      end 
    end
   
  #-----------------------------------------------------------------------------
  # Return status codes on demand
    
    describe "#[]" do
      it "testing available key with []" do
        Codes.code("abc")
        test_eq Codes.new.[]("abc"), 8
      end
      
      it "testing unavailable key with []" do
        test_eq Codes.new.[]("not_avail"), 2
      end
      
      it "testing return value sequence with []" do
        
        test_eq Codes.new.[]("abc"), 8
        Codes.code("def")
        test_eq Codes.new.[]("def"), 9
      end
    end

    #---
      
    describe "#method_missing" do
      it "testing known status code with method_missing" do
        
        test_eq Codes.new.method_missing("success"), 0
      end
      
      it"testing unknown status code with method_missing" do
        
        test_eq Codes.new.method_missing("test2"), 2
      end
    end
  end
end