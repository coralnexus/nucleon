module Nucleon
module Plugin
class Test < Nucleon.plugin_class(:nucleon, :base)

  #*****************************************************************************
  # Initialization

  def normalize(reset)
    super
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