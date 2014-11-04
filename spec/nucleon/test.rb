module Nucleon
module Plugin
class Test < Nucleon.plugin_class(:nucleon, :base)

  #*****************************************************************************
  # Initialization

  def normalize(reset)
    super
  end

  #*****************************************************************************
  # Plugin accessors / modifiers

  def test1
    get(:test1, 1)
  end

  def test1=test
    set(:test1, test)
  end


  def test2
    get(:test2, 2)
  end

  def test2=test
    set(:test2, test)
  end


  #*****************************************************************************
  # Plugin test interface

  def say_hello(to_who)
    logger.info('executing say_hello')
    yield if block_given?
    logger.info('goodbye')
  end

  def math(a, b)
    result = 0
    logger.info('executing math')
    result = yield if block_given?
    logger.info('goodbye')
    result
  end

  def exec_block(a, b, &code)
    result = nil
    logger.info('executing exec_block')
    result = yield if block_given?
    logger.info('goodbye')
    result
  end
end
end
end