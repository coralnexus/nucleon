
RSpec.shared_context "test" do

  #*****************************************************************************
  # Reusable Nucleon tests

  def test_type(this, klass)
    expect(this).to be_kind_of(klass)
  end


  def test_eq(this, that)
    expect(this).to eq(that)
  end

  def test_config(config, state)
    test_eq(config.export, state)
  end


  def test_output(message, printer = :puts)
    handle = double('output')
    expect(handle).to receive(printer).with(message)
    yield(handle) if block_given?
    handle
  end


  def test_object(klass, *args)
    object = klass.new(*args)
    yield(object) if block_given?
    object
  end
end