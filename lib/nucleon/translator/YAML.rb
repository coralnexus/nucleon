
module Nucleon
module Translator
class YAML < Nucleon.plugin_class(:nucleon, :translator)
   
  #-----------------------------------------------------------------------------
  # Translator operations
   
  def parse(yaml_text)
    return super do |properties|
      if yaml_text && ! yaml_text.empty?
        properties = Util::Data.parse_yaml(yaml_text)
      end
      properties
    end
  end
  
  #---
  
  def generate(properties)
    return super do
      Util::Data.to_yaml(properties)
    end
  end
end
end
end
