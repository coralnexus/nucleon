
module Nucleon
module Template
class YAML < Nucleon.plugin_class(:nucleon, :template)
  
  #-----------------------------------------------------------------------------
  # Renderers  
   
  def render_processed(data)
    return super do
      Util::Data.to_yaml(data)
    end    
  end
end
end
end