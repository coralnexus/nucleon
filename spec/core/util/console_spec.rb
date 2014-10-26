
require 'spec_helper'

module Nucleon

  describe Util::Console do

    include_context "nucleon_test"


    #***************************************************************************

    def console(*args, &code)
      test_object(Util::Console, *args, &code)
    end


    #***************************************************************************
    # Core IO

    # Output via a printer method to an output channel unless quiet specified
    #
    describe "#say" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :output => output }) do |console|
            console({ :console_delegate => console }).say(:info, 'message')
          end
        end
      end

      it "prints a message with default options" do
        test_output('message', :puts) do |output|
          console({ :output => output }).say(:info, 'message')
        end

        test_output('[component] message', :puts) do |output|
          console({
            :resource => 'component',
            :output   => output,
          }).say(:info, 'message')
        end
      end

      it "prints a message with and without newlines included" do
        test_output('message', :puts) do |output|
          console({ :output => output }).say(:info, 'message', { :new_line => true })
        end

        test_output('message', :print) do |output|
          console({ :output => output }).say(:info, 'message', { :new_line => false })
        end
      end

      it "routes message of different types" do
        [:info, :warn, :success, :error].each do |type|
          test_output('message', :puts) do |output|
            console({ :output => output, :color => false }).say(type, 'message')
          end
        end
      end

      it "routes message to output and error channels based on channel given" do
        [:info, :warn, :success].each do |type|
          test_output(type.to_s, :puts) do |output|
            console({ :color => false }).say(type, type.to_s, { :channel => output })
          end
        end
      end
    end

    # Dump an object to an output channel even if quiet specified
    #
    describe "#dump" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :error => output }) do |console|
            console({ :console_delegate => console }).dump('message')
          end
        end
      end

      it "dumps data to stderr output channel" do
        test_output('message', :puts) do |output|
          console({ :error => output }).dump('message')
        end
      end
    end

    # Ask terminal user for an input value
    #
    describe "#ask" do

      it "can delegate to another class that contains this method"

      it "displays a prompt and returns user feedback"
    end

    # Ask terminal user for an input value
    #
    describe "#password" do

      it "can delegate to another class that contains this method"

      it "displays a prompt and returns user feedback with user typing hidden"
    end


    #***************************************************************************
    # Specialized output

    # Output information to an output channel unless quiet specified
    #
    describe "#info" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :output => output }) do |console|
            console({ :console_delegate => console }).info('message')
          end
        end
      end

      it "prints an uncolored information message" do
        test_output('message', :puts) do |output|
          console({ :output => output }).info('message')
        end
      end
    end

    # Output warning to an output channel unless quiet specified
    #
    describe "#warn" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :output => output, :color => false }) do |console|
            console({ :console_delegate => console }).warn('message')
          end
        end
      end

      it "prints an uncolored warning message" do
        test_output('message', :puts) do |output|
          console({ :output => output, :color => false }).warn('message')
        end
      end

      it "prints a colored warning message" do
        test_output("\e\[33mmessage\e\[0m", :print) do |output|
          console({ :output => output, :color => true }).warn('message', { :new_line => false })
        end
      end
    end

    # Output error to an output channel unless quiet specified
    #
    describe "#error" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :output => output, :color => false }) do |console|
            console({ :console_delegate => console }).error('message')
          end
        end
      end

      it "prints an uncolored error message" do
        test_output('message', :puts) do |output|
          console({ :output => output, :color => false }).error('message')
        end
      end

      it "prints a colored error message" do
        test_output("\e\[31mmessage\e\[0m", :print) do |output|
          console({ :output => output, :color => true }).error('message', { :new_line => false })
        end
      end
    end

    # Output success message to an output channel unless quiet specified
    #
    describe "#success" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :output => output, :color => false }) do |console|
            console({ :console_delegate => console }).success('message')
          end
        end
      end

      it "prints an uncolored success message" do
        test_output('message', :puts) do |output|
          console({ :output => output, :color => false }).success('message')
        end
      end

      it "prints a colored success message" do
        test_output("\e\[32mmessage\e\[0m", :print) do |output|
          console({ :output => output, :color => true }).success('message', { :new_line => false })
        end
      end
    end


    #***************************************************************************
    # Utilities

    # Format a message for display
    #
    describe "#format_message" do

      it "can delegate to another class that contains this method" do
        console({ :console_delegate => console('delegate') }) do |console|
          test_eq console.format_message(:info, 'message', { :prefix => true }), '[delegate] message'
        end
      end

      it "returns without a prefix because no resource" do
        test_eq console.format_message(:info, 'message', { :prefix => true }), 'message'
      end

      it "returns without a prefix because prefix is false" do
        test_eq console('component').format_message(:info, 'message', { :prefix => false }), 'message'
      end

      it "returns without a prefix because no prefix option given" do
        test_eq console('component').format_message(:info, 'message'), 'message'
      end

      it "returns with a prefix if resource and prefix option given" do
        test_eq console('component').format_message(:info, 'message', { :prefix => true }), '[component] message'
      end

      it "formats a error message in red if color enabled" do
        test_eq console({ :resource => 'component', :color => true }).format_message(:error, 'message'), "\e\[31mmessage\e\[0m"
      end

      it "formats a warning message in yellow if color enabled" do
        test_eq console({ :resource => 'component', :color => true }).format_message(:warn, 'message'), "\e\[33mmessage\e\[0m"
      end

      it "formats a success message in green if color enabled" do
        test_eq console({ :resource => 'component', :color => true }).format_message(:success, 'message'), "\e\[32mmessage\e\[0m"
      end
    end

    # Safely output via a printer method to an output channel unless quiet specified
    #
    describe "#safe_puts" do

      it "can delegate to another class that contains this method" do
        test_output('message', :puts) do |output|
          console({ :output => output }) do |console|
            console({ :console_delegate => console }).safe_puts('message')
          end
        end
      end

      it "prints an empty string unless message given" do
        test_output('', :puts) do |output|
          console({ :output => output }).safe_puts()
        end
      end

      it "prints to different output channels if they are given" do
        console do |console|
          test_output('message1', :puts) do |output|
            console.output = output
            console.safe_puts('message1')
          end
          test_output('message2', :puts) do |output|
            console.output = output
            console.safe_puts('message2')
          end
        end
      end

      it "prints with puts if puts printer option given" do
        test_output('message', :puts) do |output|
          console({ :output => output, :printer => :puts }).safe_puts('message')
        end
      end

      it "prints with print if print printer option given" do
        test_output('message', :print) do |output|
          console({ :output => output, :printer => :print }).safe_puts('message')
        end
      end

      it "can override the instance output channel" do
        test_output('message1', :puts) do |output|
          console({ :output => output }) do |console|
            console.safe_puts('message1')
            console.safe_puts('message2', { :channel => test_output('message2', :puts) })
          end
        end
      end

      it "can override the instance printer handler" do
        test_output('message1', :puts) do |output|
          console({ :output => output, :printer => :puts }) do |console|
            console.safe_puts('message1')
            console.safe_puts('message2', { :channel => test_output('message2', :print), :printer => :print })
          end
        end
      end
    end

    # Check if a registered delegate exists and responds to a specified method.
    #
    describe "#check_delegate" do

      it "returns false if no delegate exists" do
        test_eq console.check_delegate('safe_puts'), false
      end

      it "returns true if a delegate exists and it implements given method" do
        console({ :console_delegate => console }) do |console|
          test_eq console.check_delegate('safe_puts'), true
          test_eq console.check_delegate('nonexistent'), false
        end
      end
    end
  end
end