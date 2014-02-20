
module Nucleon
class Core < Config
  
  #-----------------------------------------------------------------------------
  # Properties
  
  @@ui = Util::Interface.new("core")
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize(data = {}, defaults = {}, force = true)
    super(data, defaults, force)   
    
    class_label      = self.class.to_s.downcase.gsub(/^nucleon::/, '')
    logger_name      = delete(:logger, class_label)
    interface_config = Config.new(export).defaults({ :logger => logger_name, :resource => class_label })
    
    @ui = Util::Interface.new(interface_config)
    logger.debug("Initialized instance interface")
  end
  
  #-----------------------------------------------------------------------------
  # Accessor / Modifiers
  
  attr_accessor :ui
  
  #---
  
  def self.ui
    return @@ui
  end
  
  #---
  
  def self.logger
    return @@ui.logger
  end
  
  #--- 
   
  def logger
    return @ui.logger
  end
 
  #-----------------------------------------------------------------------------
  # General utilities
  
  def ui_group(resource)
    ui_resource = ui.resource
    ui.resource = resource
    yield
    
  ensure
    ui.resource = ui_resource  
  end 
end
end