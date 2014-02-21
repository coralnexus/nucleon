
module Nucleon
class Config
  
  #-----------------------------------------------------------------------------
  # Global interface

  extend Mixin::ConfigOptions
  extend Mixin::ConfigCollection
  
  #-----------------------------------------------------------------------------
  # Instance generators
  
  def self.ensure(config)
    case config
    when Nucleon::Config
      return config
    when Hash
      return new(config) 
    end
    return new
  end
  
  #---
  
  def self.init(options, contexts = [], hierarchy = [], defaults = {})
    contexts = contexts(contexts, hierarchy)
    config   = new(get_options(contexts), defaults)
    config.import(options) unless Util::Data.empty?(options)
    return config
  end
  
  #---
  
  def self.init_flat(options, contexts = [], defaults = {})
    return init(options, contexts, [], defaults)
  end
   
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
   
  def initialize(data = {}, defaults = {}, force = true)
    @force      = force
    @properties = {}
    
    if defaults.is_a?(Hash) && ! defaults.empty?
      defaults = symbol_map(defaults)
    end
    
    case data
    when Nucleon::Config
      @properties = Util::Data.merge([ defaults, data.export ], force)
    when Hash
      @properties = {}
      if data.is_a?(Hash)
        @properties = Util::Data.merge([ defaults, symbol_map(data) ], force)
      end  
    end
  end
  
  #-----------------------------------------------------------------------------
  # Checks
  
  def empty?
    @properties.empty?
  end
  
  #---
  
  def has_key?(keys)
    get(keys) ? true : false
  end
      
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  def keys
    @properties.keys
  end
  
  #---
    
  def fetch(data, keys, default = nil, format = false)    
    if keys.is_a?(String) || keys.is_a?(Symbol)
      keys = [ keys ]
    end    
    key = keys.shift.to_sym
    
    if data.has_key?(key)
      value = data[key]
      
      if keys.empty?
        return filter(value, format)
      else
        return fetch(data[key], keys, default, format)  
      end
    end
    return filter(default, format)
  end
  protected :fetch
  
  #---
  
  def modify(data, keys, value = nil) 
    if keys.is_a?(String) || keys.is_a?(Symbol)
      keys = [ keys ]
    end
        
    key      = keys.shift.to_sym
    has_key  = data.has_key?(key)
    existing = { 
      :key   => key, 
      :value => ( has_key ? data[key] : nil ) 
    }
    
    if keys.empty?      
      existing[:value] = data[key] if has_key
      
      if value.nil?
        data.delete(key) if has_key
      else
        data[key] = value
      end
    else      
      data[key] = {} unless has_key
      existing  = modify(data[key], keys, value)  
    end
    
    return existing
  end
  protected :modify
  
  #---
  
  def get(keys, default = nil, format = false)
    return fetch(@properties, array(keys).flatten, default, format)
  end

  #---
 
  def [](name, default = nil, format = false)
    get(name, default, format)
  end
  
  #---
  
  def get_array(keys, default = [])
    return get(keys, default, :array)
  end
  
  #---
  
  def get_hash(keys, default = {})
    return get(keys, default, :hash)
  end
  
  #---
  
  def init(keys, default = nil)
    return set(keys, get(keys, default))
  end

  #---
  
  def set(keys, value)
    modify(@properties, array(keys).flatten, value)
    return self
  end
  
  #---
  
  def []=(name, value)
    set(name, value)
  end
   
  #---
  
  def delete(keys, default = nil)
    existing = modify(@properties, array(keys).flatten, nil)
    return existing[:value] if existing[:value]
    return default
  end
  
  #---
  
  def clear
    @properties = {}
    return self
  end

  #-----------------------------------------------------------------------------
  # Import / Export
 
  def import_base(properties, options = {})
    config      = Config.new(options, { :force => @force }).set(:context, :hash)    
    import_type = config.get(:import_type, :override)
    
    properties  = properties.export if properties.is_a?(Nucleon::Config)
    
    case properties
    when Hash
      data = [ @properties, symbol_map(properties) ]
      data = data.reverse if import_type != :override
      
      @properties = Util::Data.merge(data, config)
    
    when String, Symbol
      properties = self.class.lookup(properties.to_s, {}, config)
      
      data = [ @properties, symbol_map(properties) ]
      data = data.reverse if import_type != :override
    
      @properties = Util::Data.merge(data, config)
     
    when Array
      properties.each do |item|
        import_base(item, config)
      end
    end
    
    return self
  end
  protected :import_base
  
  #---
  
  def import(properties, options = {})
    return import_base(properties, options)
  end
  
  #---
  
  def defaults(defaults, options = {})
    config = Config.new(options).set(:import_type, :default)
    return import_base(defaults, config)
  end

  #---
  
  def export
    return @properties
  end
  
  #-----------------------------------------------------------------------------
  # Utilities

  def self.symbol_map(data)
    return Util::Data.symbol_map(data)
  end
  
  #---
  
  def symbol_map(data)
    return self.class.symbol_map(data)
  end
  
  #---
  
  def self.string_map(data)
    return Util::Data.string_map(data)
  end
  
  #---
  
  def string_map(data)
    return self.class.string_map(data)
  end
  
  #-----------------------------------------------------------------------------
      
  def self.filter(data, method = false)
    return Util::Data.filter(data, method)
  end
  
  #---
  
  def filter(data, method = false)
    return self.class.filter(data, method)
  end
    
  #-----------------------------------------------------------------------------
          
  def self.array(data, default = [], split_string = false)
    return Util::Data.array(data, default, split_string)
  end
  
  #---
  
  def array(data, default = [], split_string = false)
    return self.class.array(data, default, split_string)
  end
    
  #---
        
  def self.hash(data, default = {})
    data = data.export if data.is_a?(Nucleon::Config)
    return Util::Data.hash(data, default)
  end
  
  #---
  
  def hash(data, default = {})
    return self.class.hash(data, default)
  end
    
  #---
         
  def self.string(data, default = '')
    return Util::Data.string(data, default)
  end
  
  #---
  
  def string(data, default = '')
    return self.class.string(data, default)
  end
    
  #---
         
  def self.symbol(data, default = :undefined)
    return Util::Data.symbol(data, default)
  end
  
  #---
  
  def symbol(data, default = :undefined)
    return self.class.symbol(data, default)
  end
     
  #---
    
  def self.test(data)
    return Util::Data.test(data)
  end
  
  #---
  
  def test(data)
    return self.class.test(data)
  end  
end
end
