
module Nucleon
module Template
class JSON < Nucleon.plugin_class(:nucleon, :template)
  
  #-----------------------------------------------------------------------------
  # Renderers  
   
  def render_processed(data)
    return super do
      Util::Data.to_json(data)
    end
  end
end
end
end