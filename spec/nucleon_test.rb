
RSpec.shared_context "test" do

  #*****************************************************************************
  # Reusable Nucleon tests

  def test_eq(this, that)
    expect(this).to eq(that)
  end

  def test_config(config, state)
    test_eq(config.export, state)
  end
end