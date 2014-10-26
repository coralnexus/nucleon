
require 'spec_helper'

module Nucleon

  describe Codes do

    include_context "nucleon_test"
    include_context "nucleon_codes"

    #***************************************************************************

    def codes(*args, &code)
      test_object(Codes, *args, &code)
    end


    #***************************************************************************
    # Global collections

    # Return the codes registry object
    #
    describe "#registry" do

      it "returns the global code registry hash" do
        test_eq Codes.registry, codes_registry_custom
      end
    end

    # Return the codes status index object
    #
    describe "#status_index" do

      it "returns the global status index hash" do
        test_eq Codes.status_index, codes_status_index_custom
      end
    end


    #***************************************************************************
    # Global collections

    # Return status index information for specified codes
    #
    describe "#index" do

      it "returns the global status index if no code requested" do
         test_eq Codes.index, codes_status_index_custom
         test_eq Codes.index(nil), codes_status_index_custom
      end

      it "returns the appropriate code label if it exists" do
        test_eq Codes.index(0), "success"
        test_eq Codes.index(1), "help_wanted"
        test_eq Codes.index(2), "unknown_status"
        test_eq Codes.index(3), "action_unprocessed"
        test_eq Codes.index(4), "batch_error"
        test_eq Codes.index(5), "validation_failed"
        test_eq Codes.index(6), "access_denied"
        test_eq Codes.index(7), "good"
        test_eq Codes.index(8), "bad"
        test_eq Codes.index(9), "ok"
        test_eq Codes.index(10), "wow"
        test_eq Codes.index(11), "whew"
      end

      it "returns the unknown status label if the code does not exist" do
        test_eq Codes.index(100), "unknown_status"
      end
    end

    # Return status index information for specified codes
    #
    describe "#render_index" do

      it "renders known status code information with selected code if specified" do
        for status_code in 0 .. 11
          test_eq Codes.render_index(status_code), codes_rendered_index(status_code)
        end
      end

      it "renders status index without selected code if unknown status code specified" do
          test_eq Codes.render_index(100), codes_rendered_index(100)
      end
    end

    #***************************************************************************
    # Code construction

    # Add a status code name to the global collection to receive unique status code
    #
    describe "#code" do

      it "adds a non existing status code identifier to the global collection" do
        Codes.code("my_code")

        test_eq codes["my_code"], 12
        test_eq codes[:my_code], 12
      end

      it "leaves an existing status code identifier in the global collection" do
        Codes.code(:unknown_status)

        test_eq codes["unknown_status"], 2
        test_eq codes[:unknown_status], 2
      end
    end

    # Add multiple status code names to the global collection to receive unique status codes
    #
    describe "#codes" do

      it "adds non existing status code identifiers to the global collection" do
        Codes.codes("my_code1", :batch_error, :my_code2, "success", "yay")

        test_eq codes["my_code1"], 12
        test_eq codes[:my_code1], 12
        test_eq codes["batch_error"], 4
        test_eq codes[:batch_error], 4
        test_eq codes["my_code2"], 13
        test_eq codes[:my_code2], 13
        test_eq codes["success"], 0
        test_eq codes[:success], 0
        test_eq codes["yay"], 14
        test_eq codes[:yay], 14
      end
    end

    # Add multiple status code names to the global collection to receive unique status codes
    #
    describe "#reset" do

      it "clears all custom codes and reverts registry to default state" do
        Codes.codes("my_code1", :batch_error, :my_code2, "success", "yay")
        Codes.reset

        test_eq Codes.registry, codes_registry_clean
        test_eq Codes.status_index, codes_status_index_clean
      end
    end


    #***************************************************************************
    # Code access

    # Return the code for a specified code identifier
    #
    describe "#[]" do

      it "returns an status code for an existing identifier" do
        test_eq codes["ok"], 9
        test_eq codes[:ok], 9
        test_eq codes["batch_error"], 4
        test_eq codes[:batch_error], 4
        test_eq codes["whew"], 11
        test_eq codes[:whew], 11
        test_eq codes["success"], 0
        test_eq codes[:success], 0
      end

      it "returns the unknown status code if no existing identifier" do
        test_eq codes["not_ok"], 2
        test_eq codes[:not_ok], 2
        test_eq codes["batchy_error"], 2
        test_eq codes[:batchy_error], 2
      end
    end

    # Return the code for a specified code identifier
    #
    describe "#method_missing" do

      it "returns the proper status code for existing identifier methods" do
        test_eq codes.success, 0
        test_eq codes.help_wanted, 1
        test_eq codes.unknown_status, 2
        test_eq codes.action_unprocessed, 3
        test_eq codes.batch_error, 4
        test_eq codes.validation_failed, 5
        test_eq codes.access_denied, 6
        test_eq codes.good, 7
        test_eq codes.bad, 8
        test_eq codes.ok, 9
        test_eq codes.wow, 10
        test_eq codes.whew, 11
      end

      it"returns the unknown status code for non existing identifier methods" do
        test_eq codes.doesnt_exist, 2
        test_eq codes.so_sorry, 2
      end
    end
  end
end