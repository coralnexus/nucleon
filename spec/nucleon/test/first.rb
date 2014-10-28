module Nucleon
module Test
class First < Nucleon.plugin_class(:nucleon, :test)

  #*****************************************************************************
  # Plugin test interface

  def say_hello(to_who)
    super do
      info("Hello there #{to_who}", { :i18n => false })
    end
  end

  def math(a, b)
    super do
      a * b
    end
  end

  def exec_block(a, b, &code)
    super do
      z = -1
      z = code.call(10, 20, a, b) if code
    end
  end
end
end
end