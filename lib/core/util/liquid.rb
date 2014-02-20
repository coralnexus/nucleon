
module Nucleon
module Util
class Liquid

  def initialize(&code)
    @code = code  
  end
  
  #---
  
  def method_missing(method, *args, &block)  
    @code.call(method, args, block)
  end   
end
end
end
