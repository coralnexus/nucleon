module Nucleon
module Test
class Second < Nucleon.plugin_class(:nucleon, :test)

  #*****************************************************************************
  # Plugin test interface

  def say_hello(to_who)
    super do
      info("Greetings #{to_who}", { :i18n => false })
    end
  end

  def math(a, b)
    super do
      a + b
    end
  end

  def exec_block(a, b, &code)
    super do
      z = -20
      z = code.call(100, -8, a, b) if code
    end
  end
end
end
end