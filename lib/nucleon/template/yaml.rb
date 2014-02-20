
module Nucleon
module Template
class Yaml < Plugin::Template
  
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