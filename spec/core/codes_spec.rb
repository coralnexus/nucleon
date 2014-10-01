require 'spec_helper'

module Nucleon
  describe Codes do
    
    #-----------------------------------------------------------------------------
    # Code index
    
    describe "#registry" do
      it "tests return value is hash using registry" do
        expect(Codes.registry.is_a?(Hash)).to eq true
      end
    end
    
    #---
  
    describe "#index" do
      it "testing nil parameter with index" do
         expect(Codes.index(nil).is_a?(Hash)).to eq true
      end
      
      it "testing known status code with index" do
        expect(Codes.index(0)).to eq "success"
      end
      
      it "testing unknown status code with index" do
        expect(Codes.index(100)).to eq "unknown_status"
      end
    end
    
    #---
  
    describe "#render_index" do
      it "testing with known status code parameter with render_index" do
        for i in 0 .. 6
          expect(Codes.render_index(i).include? "[   #{i} ]").to eq true
        end
      end
      
      it "testing with unknown status code parameter with render_index" do
          expect(Codes.render_index(100).include? "[   100 ]").to eq false
      end
    end
    
  #-----------------------------------------------------------------------------
  # Code construction
  
    describe "#code" do
      it "testing nil return value on sending available key to code" do
        expect(Codes.code("success")).to eq nil
      end
      
      it "testing return value on sending unavailable key to code" do
        expect(Codes.code("test1")).to eq "test1"
      end 
    end
   
    #---
      
   # describe "#codes" do
      # it "A small example" do
        # puts Codes.codes("example")
      # end
   # end
    
  #-----------------------------------------------------------------------------
  # Return status codes on demand
    
    describe "#[]" do
      it "testing available key with []" do
        Codes.code("abc")
        expect(Codes.new.[]("abc")).to eq 8
      end
      
      it "testing unavailable key with []" do
        expect(Codes.new.[]("xyz")).to eq 2
      end
      
      it "testing return value sequence with []" do
        expect(Codes.new.[]("abc")).to eq 8
        Codes.code("def")
        expect(Codes.new.[]("def")).to eq 9
      end
    end

    #---
      
    describe "#method_missing" do
      it "testing known status code with method_missing" do
        expect(Codes.new.method_missing("success")).to eq 0
      end
      
      it"testing unknown status code with method_missing" do
        expect(Codes.new.method_missing("test2")).to eq 2
      end
    end
  end
end