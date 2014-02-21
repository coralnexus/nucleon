
require 'spec_helper'

module Nucleon

  describe Util::Console do

    #---------------------------------------------------------------------------
    # UI functionality
    
    describe "#say" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        output  = double('output')
        output.should_receive(:puts).with('message')
        
        ui = Util::Console.new({
          :output  => output,
          :printer => :puts,
        })        
        Util::Console.new({ :console_delegate => ui }).say(:info, 'message')
      end
      
      #-------------------------------------------------------------------------
      # Output formats

      it "prints a message with default options" do
        output1 = double('output1')
        output1.should_receive(:puts).with('message')
        
        Util::Console.new({ :output => output1 }).say(:info, 'message')
        
        output2 = double('output2')
        output2.should_receive(:puts).with('[component] message')
        
        Util::Console.new({
          :resource => 'component', 
          :output   => output2, 
        }).say(:info, 'message')      
      end
      
      #---
      
      it "prints a message with and without newlines included" do
        output1 = double('output1')
        output1.should_receive(:puts).with('message')
        
        test = Util::Console.new({ :output => output1 })
        test.say(:info, 'message', { :new_line => true })
        
        output2 = double('output2')
        output2.should_receive(:print).with('message')
        
        test = Util::Console.new({ :output => output2 })
        test.say(:info, 'message', { :new_line => false })      
      end
      
      #---
      
      it "routes message to output and error channels based on type given" do       
        [:info, :warn, :success].each do |type|
          output = double('output')
          output.should_receive(:puts).with('message')
        
          Util::Console.new({
            :output  => output,
            :printer => :puts,
            :color   => false,
          }).say(type, 'message')
        end
        
        error = double('error')
        error.should_receive(:puts).with('message')
        
        Util::Console.new({
          :error   => error,
          :printer => :puts,
          :color   => false,
        }).say(:error, 'message')   
      end
      
      #---
      
      it "routes message to output and error channels based on channel given" do
        [:info, :warn, :success].each do |type|
          output = double('output')
          output.should_receive(:puts).with('message')
        
          Util::Console.new({
            :output  => output,
            :printer => :puts,
          }).say(:info, 'message', { :channel => type })        
        end
        
        error = double('error')
        error.should_receive(:puts).with('message')
        
        Util::Console.new({
          :error   => error,
          :printer => :puts,
          :color   => false,
        }).say(:info, 'message', { :channel => :error })
      end  
    end
    
    #---
    
    describe "#ask" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method"
      
      #-------------------------------------------------------------------------
      # Input
      
      it "displays a prompt and returns user feedback"
    end
    
    #---
    
    describe "#info" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        output  = double('output')
        output.should_receive(:puts).with('message')
        
        ui = Util::Console.new({
          :output  => output,
          :printer => :puts,
        })        
        Util::Console.new({ :console_delegate => ui }).info('message')
      end
      
      #-------------------------------------------------------------------------
      # Printing
      
      it "prints an uncolored information message" do
        output = double('output')
        output.should_receive(:puts).with('message')
        
        Util::Console.new({ 
          :output  => output,
          :printer => :puts, 
        }).info('message')
      end    
    end
    
    #---
    
    describe "#warn" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        output  = double('output')
        output.should_receive(:puts).with('message')
        
        ui = Util::Console.new({
          :output  => output,
          :printer => :puts,
          :color   => false,
        })        
        Util::Console.new({ :console_delegate => ui }).warn('message')
      end
      
      #-------------------------------------------------------------------------
      # Printing
      
      it "prints an uncolored warning message" do
        output = double('output')
        output.should_receive(:puts).with('message')
        
        Util::Console.new({ 
          :output  => output,
          :printer => :puts,
          :color   => false, 
        }).warn('message')
      end
      
      #---
      
      it "prints a colored warning message" do
        output = double('output')
        output.should_receive(:print).with(/^\e\[33mmessage\e\[0m$/)
        
        Util::Console.new({ 
          :output => output,
          :color  => true, 
        }).warn('message', { :new_line => false })
      end    
    end
    
    #---
    
    describe "#error" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        error  = double('error')
        error.should_receive(:puts).with('message')
        
        ui = Util::Console.new({
          :error   => error,
          :printer => :puts,
          :color   => false,
        })        
        Util::Console.new({ :console_delegate => ui }).error('message')
      end
      
      #-------------------------------------------------------------------------
      # Printing
      
      it "prints an uncolored error message" do
        error = double('error')
        error.should_receive(:puts).with('message')
        
        Util::Console.new({ 
          :error   => error,
          :printer => :puts,
          :color   => false, 
        }).error('message')
      end
      
      #---
      
      it "prints a colored error message" do
        error = double('error')
        error.should_receive(:print).with(/^\e\[31mmessage\e\[0m$/)
        
        Util::Console.new({ 
          :error => error,
          :color => true, 
        }).error('message', { :new_line => false })
      end 
    end
    
    #---
    
    describe "#success" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        output  = double('output')
        output.should_receive(:puts).with('message')
        
        ui = Util::Console.new({
          :output  => output,
          :printer => :puts,
          :color   => false,
        })        
        Util::Console.new({ :console_delegate => ui }).success('message')
      end
      
      #-------------------------------------------------------------------------
      # Printing
      
      it "prints an uncolored success message" do
        output = double('output')
        output.should_receive(:puts).with('message')
        
        Util::Console.new({ 
          :output  => output,
          :printer => :puts,
          :color   => false, 
        }).success('message')
      end
      
      #---
      
      it "prints a colored success message" do
        output = double('output')
        output.should_receive(:print).with(/^\e\[32mmessage\e\[0m$/)
        
        Util::Console.new({ 
          :output => output,
          :color  => true, 
        }).success('message', { :new_line => false })
      end  
    end
  
    #---------------------------------------------------------------------------
    # Utilities
    
    describe "#format_message" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        message = Util::Console.new({ 
          :console_delegate => Util::Console.new('delegate')
        }).format_message(:info, 'message', { :prefix => true })
        
        message.should == '[delegate] message'
      end
    
      #-------------------------------------------------------------------------
      # Prefix specifications
      
      it "returns without a prefix because no resource" do
        message = Util::Console.new.format_message(:info, 'message', { :prefix => true })
        message.should == 'message'
      end
      
      #---
      
      it "returns without a prefix because prefix is false" do
        message = Util::Console.new('component').format_message(:info, 'message', { :prefix => false })
        message.should == 'message'
      end
      
      #---
            
      it "returns without a prefix because no prefix option given" do
        message = Util::Console.new('component').format_message(:info, 'message')
        message.should == 'message'
      end
      
      #---
            
      it "returns with a prefix if resource and prefix option given" do
        message = Util::Console.new('component').format_message(:info, 'message', { :prefix => true })
        message.should == '[component] message'
      end
      
      #-------------------------------------------------------------------------
      # Color specifications
      
      it "formats a error message in red if color enabled" do
        message = Util::Console.new({
          :resource => 'component',
          :color    => true,
        }).format_message(:error, 'message')
        message.should match(/^\e\[31mmessage\e\[0m$/)
      end
      
      #---
      
      it "formats a warning message in yellow if color enabled" do
        message = Util::Console.new({
          :resource => 'component',
          :color    => true,
        }).format_message(:warn, 'message')
        message.should match(/^\e\[33mmessage\e\[0m$/)
      end
      
      #---
      
      it "formats a success message in green if color enabled" do
        message = Util::Console.new({
          :resource => 'component',
          :color    => true,
        }).format_message(:success, 'message')
        message.should match(/^\e\[32mmessage\e\[0m$/)
      end
    end
    
    #---------------------------------------------------------------------------
    
    describe "#safe_puts" do
    
      #-------------------------------------------------------------------------
      # Delegation
      
      it "can delegate to another class that contains this method" do
        output  = double('output')
        output.should_receive(:puts).with('message')
        
        ui = Util::Console.new({
          :output  => output,
          :printer => :puts,
        })        
        Util::Console.new({ :console_delegate => ui }).safe_puts('message')
      end
      
      #-------------------------------------------------------------------------
      # Instance configuration
      
      it "prints an empty string unless message given" do
        output  = double('output')
        output.should_receive(:puts).with('')
        
        Util::Console.new({
          :output  => output,
          :printer => :puts,
        }).safe_puts()
      end
      
      #---
      
      it "prints to different output channels if they are given" do
        output1 = double('output1')
        output1.should_receive(:puts).with('message')
        
        test = Util::Console.new({
          :output  => output1,
          :printer => :puts,
        })
        test.safe_puts('message')
        
        output2 = double('output2')
        output2.should_receive(:puts).with('message')
        
        test.output = output2
        test.safe_puts('message')
      end
      
      #---
      
      it "prints with puts if puts printer option given" do
        output = double('output')
        output.should_receive(:puts).with('message')
        
        Util::Console.new({
          :output  => output,
          :printer => :puts,
        }).safe_puts('message')
      end
      
      #---
      
      it "prints with print if print printer option given" do
        output = double('output')
        output.should_receive(:print).with('message')
        
        Util::Console.new({
          :output  => output,
          :printer => :print,
        }).safe_puts('message')
      end
      
      #-------------------------------------------------------------------------
      # Method configuration
      
      it "can override the instance output channel" do
        output1 = double('output1')
        output1.should_not_receive(:puts).with('message')
        
        output2 = double('output2')
        output2.should_receive(:puts).with('message')
        
        Util::Console.new({
          :output  => output1,
          :printer => :puts,
        }).safe_puts('message', { :channel => output2 })  
      end
      
      #---
      
      it "can override the instance printer handler" do
        output = double('output')
        output.should_not_receive(:puts).with('message')
        output.should_receive(:print).with('message')
        
        Util::Console.new({
          :output  => output,
          :printer => :puts,
        }).safe_puts('message', { :printer => :print })
      end
    end
    
    #---------------------------------------------------------------------------
    
    describe "#check_delegate" do
      
      it "returns false if no delegate exists" do
        Util::Console.new.check_delegate('safe_puts').should be_false
      end
      it "returns true if a delegate exists and it implements given method" do
        test = Util::Console.new({ :console_delegate => Util::Console.new })
        test.check_delegate('safe_puts').should be_true
        test.check_delegate('nonexistent').should be_false
      end
    end  
  end
end