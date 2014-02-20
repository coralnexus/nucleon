
module Nucleon
module Translator
class Json < Plugin::Translator
   
  #-----------------------------------------------------------------------------
  # Translator operations
   
  def parse(json_text)
    return super do |properties|
      if json_text && ! json_text.empty?
        properties = Util::Data.parse_json(json_text)
      end
      properties
    end
  end
  
  #---
  
  def generate(properties)
    return super do
      Util::Data.to_json(properties, get(:pretty, true))
    end
  end
end
end
end
