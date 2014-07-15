
module Nucleon
class Core < Config
  
  include Mixin::Colors
  
  #-----------------------------------------------------------------------------
  # Properties
  
  @@logger  = Util::Logger.new('core')
  @@ui      = Util::Console.new('core')
  @@ui_lock = Mutex.new
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize(data = {}, defaults = {}, force = true, set_initialized = true, basic_merge = true)
    super(data, defaults, force, basic_merge)   
    
    @class_color = Util::Data.ensure_value(delete(:class_color, :cyan), :cyan)
    @class_label = self.class.to_s.downcase.gsub(/^nucleon::/, '')
    
    self.logger = delete(:logger, @class_label)
    self.ui     = Config.new(export).defaults({ :resource => Util::Console.colorize(@class_label, @class_color) })
    
    logger.debug('Initialized instance logger and interface')
    @initialized = true if set_initialized
  end
  
  #-----------------------------------------------------------------------------
  # Checks
  
  def initialized?
    @initialized
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
  
  def self.ui_group(resource, color = :cyan)
    @@ui_lock.synchronize do
      begin
        ui_resource = ui.resource
        ui.resource = Util::Console.colorize(resource, color)
        yield(ui)
    
      ensure
        ui.resource = ui_resource
      end
    end  
  end 
  
  #---
  
  def ui_group(resource, color = :cyan)
    ui_resource = ui.resource
    ui.resource = Util::Console.colorize(resource, color)
    yield(ui)
    
  ensure
    ui.resource = ui_resource  
  end 
end
end