
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
    
    self.logger = delete(:logger, class_label)
    self.ui     = Config.new(export).defaults({ :resource => class_label })
    
    logger.debug('Initialized instance logger and interface')
  end
  
  #-----------------------------------------------------------------------------
  # Accessor / Modifiers
  
  attr_reader :logger, :ui
  
  #---
  
  def self.logger
    return @@logger
  end
  
  def logger=logger
    Util::Logger.loggers.delete(self.logger.resource) if self.logger
    
    if logger.is_a?(Util::Logger)
      @logger = logger
    else
      @logger = Util::Logger.new(logger)
    end
  end
  
  #---
  
  def self.ui
    return @@ui
  end
  
  def ui=ui
    if ui.is_a?(Util::Console)
      @ui = ui
    else
      @ui = Util::Console.new(ui)
    end  
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