
module Nucleon
module Template
class Json < Plugin::Template
  
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