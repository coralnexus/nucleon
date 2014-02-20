
module Nucleon
class Core < Config
  
  #-----------------------------------------------------------------------------
  # Properties
  
  @@logger = Util::Logger.new('core')
  @@ui     = Util::Console.new('core')
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize(data = {}, defaults = {}, force = true)
    super(data, defaults, force)   
    
    class_label = self.class.to_s.downcase.gsub(/^nucleon::/, '')
    
    @logger = Util::Logger.new(delete(:logger, class_label))
    @ui     = Util::Console.new(Config.new(export).defaults({ :resource => class_label }))
    
    logger.debug('Initialized instance logger and interface')
  end
  
  #-----------------------------------------------------------------------------
  # Accessor / Modifiers
  
  attr_accessor :logger, :ui
  
  #---
  
  def self.logger
    return @@logger
  end
  
  #---
  
  def self.ui
    return @@ui
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