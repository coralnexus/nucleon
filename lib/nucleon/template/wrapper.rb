
module Nucleon
module Template
class Wrapper < Nucleon.plugin_class(:nucleon, :template)
  
  #-----------------------------------------------------------------------------
  # Renderers  
   
  def render_processed(data)
    return super do
      get(:template_prefix, '') + data.to_s + get(:template_suffix, '')
    end
  end
end
end
end