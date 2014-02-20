
# Should be included via include
#
# include Mixin::SubConfig
#

module Nucleon
module Mixin
module SubConfig
  
  #-----------------------------------------------------------------------------
  # Initialization
  
  def init_subconfig(reset = false)
    return if @subconfig_initialized && ! reset
    
    unless @config
      @config = Config.new
    end
    
    @subconfig_initialized = true
  end
  protected :init_subconfig
  
  #-----------------------------------------------------------------------------
  # Propety accessors / modifiers
  
  def config
    return @config
  end
  
  #---
  
  def config=config
    @config = config
  end
    
  #-----------------------------------------------------------------------------

  def _get(keys, default = nil, format = false)
    return fetch(@properties, array(keys).flatten, default, format)
  end
  protected :_get
  
  #---
  
  def get(keys, default = nil, format = false)
    init_subconfig
    return config.get(keys, default, format)
  end
  
  #---
  
  def _init(keys, default = nil)
    return _set(keys, _get(keys, default))
  end
  protected :_init

  #---
 
  def _set(keys, value = '')
    modify(@properties, array(keys).flatten, value)
  end
  protected :_set
  
  #---
    
  def set(keys, value = '')
    init_subconfig
    config.set(keys, value)
  end
  
  #---
 
  def _delete(keys, default = nil)
    existing = modify(@properties, array(keys).flatten, nil)
    return existing[:value] if existing[:value]
    return default 
  end
  protected :_delete
  
  #---
   
  def delete(keys, default = nil)
    init_subconfig
    config.delete(keys, default)
  end
 
  #---
 
  def _clear
    @properties = {}
  end
  protected :_clear
  
  #---
  
  def clear
    init_subconfig
    config.clear
  end
  
  #-----------------------------------------------------------------------------
  # Import / Export
  
  def _import(properties, options = {})
    return import_base(properties, options)
  end
  protected :_import
  
  #---
  
  def import(properties, options = {})
    init_subconfig
    config.import(properties, options)
  end
  
  #---
  
  def _defaults(defaults, options = {})
    config = new(options).set(:import_type, :default)
    return import_base(defaults, config)
  end
  protected :_defaults
  
  #---
  
  def defaults(defaults, options = {})
    init_subconfig
    config.defaults(defaults, options)
  end
  
  #---
  
  def _export
    return @properties
  end
  protected :_export
  
  #---
  
  def export
    init_subconfig
    return config.export
  end
end
end
end