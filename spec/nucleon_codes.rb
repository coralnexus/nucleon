

RSpec.shared_context "nucleon_codes" do

  #*****************************************************************************
  # Code initialization

  let(:codes_registry_clean) do {
      :success            => 0,
      :help_wanted        => 1,
      :unknown_status     => 2,
      :action_unprocessed => 3,
      :batch_error        => 4,
      :validation_failed  => 5,
      :access_denied      => 6
    }
  end

  let(:codes_status_index_clean) do {
      0 => "success",
      1 => "help_wanted",
      2 => "unknown_status",
      3 => "action_unprocessed",
      4 => "batch_error",
      5 => "validation_failed",
      6 => "access_denied"
    }
  end


  let(:codes_registry_custom) do {
      :success            => 0,
      :help_wanted        => 1,
      :unknown_status     => 2,
      :action_unprocessed => 3,
      :batch_error        => 4,
      :validation_failed  => 5,
      :access_denied      => 6,
      :good               => 7,
      :bad                => 8,
      :ok                 => 9,
      :wow                => 10,
      :whew               => 11
    }
  end

  let(:codes_status_index_custom) do {
      0 => "success",
      1 => "help_wanted",
      2 => "unknown_status",
      3 => "action_unprocessed",
      4 => "batch_error",
      5 => "validation_failed",
      6 => "access_denied",
      7 => "good",
      8 => "bad",
      9 => "ok",
      10 => "wow",
      11 => "whew"
    }
  end


  before(:each) do
    # Set custom codes before every test
    Nucleon::Codes.reset # 0 - 6 reserved
    Nucleon::Codes.codes(:good, :bad, :ok, :wow, :whew) # 7 - ?
  end


  #*****************************************************************************
  # Code test utilities

  def codes_rendered_index(status_code = nil)
    # Basically copied from the Codes class to ensure parity over time.
    output = "Status index:\n"
    codes_status_index_custom.each do |code, name|
      name = name.gsub(/_/, ' ').capitalize

      if ! status_code.nil? && status_code == code
        output << sprintf(" [ %3i ] - %s\n", code, name)
      else
        output << sprintf("   %3i   - %s\n", code, name)
      end
    end
    output << "\n"
    output
  end
end