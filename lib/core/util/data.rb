
module Nucleon
module Util
class Data
  
  #-----------------------------------------------------------------------------
  # Type checking
  
  def self.undef?(value)
    if value.nil? || 
      (value.is_a?(Symbol) && value == :undef || value == :undefined) || 
      (value.is_a?(String) && value.match(/^\s*(undef|UNDEF|Undef|nil|NIL|Nil)\s*$/))
      return true
    end
    return false  
  end
  
  #---
  
  def self.true?(value)
    if value == true || 
      (value.is_a?(String) && value.match(/^\s*(true|TRUE|True)\s*$/))
      return true
    end
    return false  
  end
  
  #---
  
  def self.false?(value)
    if value == false || 
      (value.is_a?(String) && value.match(/^\s*(false|FALSE|False)\s*$/))
      return true
    end
    return false  
  end
  
  #---
  
  def self.empty?(value)
    if undef?(value) || false?(value) || (value.respond_to?('empty?') && value.empty?)
      return true
    end
    return false
  end
  
  #---
  
  def self.exists?(data, keys, check_empty = false)
    if keys.is_a?(String) || keys.is_a?(Symbol)
      keys = [ keys ]
    end    
    key = keys.shift.to_sym
    
    if data.has_key?(key)
      value = data[key]
      
      if keys.empty?
        return false if check_empty && empty?(value)
        return true
      else
        return exists?(data[key], keys)  
      end
    end
    return false
  end
   
  #-----------------------------------------------------------------------------
  # Translation

  def self.symbol_map(data)
    results = {}
    return data unless data
    
    case data
    when Hash
      data.each do |key, value|
        results[key.to_sym] = symbol_map(value)
      end
    else
      results = data
    end    
    return results
  end
  
  #---
  
  def self.string_map(data)
    results = {}
    return data unless data
    
    case data
    when Hash
      data.each do |key, value|
        results[key.to_s] = string_map(value)
      end
    else
      results = data
    end    
    return results
  end
  
  #---
  
  def self.parse_json(json_text)
    return MultiJson.load(json_text)
  end
    
  #---
  
  def self.to_json(data, pretty = true)
    return MultiJson.dump(data, :pretty => pretty)
  end
  
  #---
  
  def self.parse_yaml(yaml_text)
    return YAML.load(yaml_text)
  end
  
  #---
  
  def self.to_yaml(data)
    return YAML.dump(data)
  end
  
  #---
  
  def self.value(value)
    case value
    when String
      if undef?(value)
        value = nil
      elsif true?(value)
        value = true
      elsif false?(value)
        value = false
      end
    
    when Array
      value.each_with_index do |item, index|
        value[index] = value(item)
      end
    
    when Hash
      value.each do |key, data|
        value[key] = value(data)
      end
    end
    return value  
  end
  
  #---
      
  def self.filter(data, method = false)
    if method && method.is_a?(Symbol) && 
      [ :array, :hash, :string, :symbol, :test ].include?(method.to_sym)
      return send(method, data)
    end
    return data
  end
  
  #---
          
  def self.array(data, default = [], split_string = false)
    result = default    
    if data
      case data
      when Array
        result = data
      when String
        result = [ ( split_string ? data.split(/\s*,\s*/) : data ) ]
      else
        result = [ data ]
      end
    end
    return result
  end
    
  #---
        
  def self.hash(data, default = {})
    result = default    
    if data
      case data
      when Hash
        result = data
      else
        result = {}
      end
    end
    return result
  end
    
  #---
         
  def self.string(data, default = '')
    result = default    
    if data
      case data
      when String
        result = data
      else
        result = data.to_s
      end
    end
    return result
  end
    
  #---
         
  def self.symbol(data, default = :undefined)
    result = default    
    if data
      case data
      when Symbol
        result = data
      when String
        result = data.to_sym
      else
        result = data.class.to_sym
      end
    end
    return result
  end
     
  #---
    
  def self.test(data)
    return false if Util::Data.empty?(data)
    return true
  end
    
  #-----------------------------------------------------------------------------
  # Operations
  
  def self.clean(data)
    data.keys.each do |key|
      data.delete(key) if data[key].nil?
    end
    data
  end
  
  #---
  
  def self.merge(data, force = true)
    value = data
    
    # Special case because this method is called from within Config.new so we 
    # can not use Config.ensure, as that would cause an infinite loop.
    force = force.is_a?(Nucleon::Config) ? force.get(:force, true) : force
    
    if data.is_a?(Array)
      value = undef?(data[0]) ? nil : data.shift.clone
      
      data.each do |item|
        item = undef?(item) ? nil : item.clone
        
        case value
        when Hash
          begin
            require 'deep_merge'
            value = force ? value.deep_merge!(item) : value.deep_merge(item)
            
          rescue LoadError
            if item.is_a?(Hash) # Non recursive top level by default.
              value = value.merge(item)              
            elsif force
              value = item
            end
          end  
        when Array
          if item.is_a?(Array)
            value = value.concat(item).uniq
          elsif force
            value = item
          end
                
        else
          value = item if force || item.is_a?(String) || item.is_a?(Symbol)
        end
      end  
    end
    
    return value
  end

  #---
  
  def self.interpolate(value, scope, options = {})    
    
    pattern = ( options.has_key?(:pattern) ? options[:pattern] : '\$(\{)?([a-zA-Z0-9\_\-]+)(\})?' )
    group   = ( options.has_key?(:var_group) ? options[:var_group] : 2 )
    flags   = ( options.has_key?(:flags) ? options[:flags] : '' )
    
    if scope.is_a?(Hash)
      regexp = Regexp.new(pattern, flags.split(''))
    
      replace = lambda do |item|
        matches = item.match(regexp)
        result  = nil
        
        unless matches.nil?
          replacement = scope.search(matches[group], options)
          result      = item.gsub(matches[0], replacement) unless replacement.nil?
        end
        return result
      end
      
      case value
      when String
        while (temp = replace.call(value))
          value = temp
        end
        
      when Hash
        value.each do |key, data|
          value[key] = interpolate(data, scope, options)
        end
      end
    end
    return value  
  end
  
  #---
  
  def self.rm_keys(data, keys)
    keys = [ keys ] unless keys.is_a?(Array)
    keys.each do |key|
      data.delete(key)
    end
    data
  end
  
  #---
  
  def self.subset(data, keys)
    keys     = [ keys ] unless keys.is_a?(Array)
    new_data = {} 
    keys.each do |key|
      new_data[key] = data[key] if data.has_key?(key)
    end
    new_data 
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.prefix(prefix, data)
    result = nil
    
    unless prefix.is_a?(String) && ! empty?(prefix)
      prefix = ''
    end
    
    case data
    when String, Symbol
      result = ( prefix.empty? ? data.to_s : prefix + '_' + data.to_s )
      
    when Array
      result = []
      data.each do |value|
        result << prefix(prefix, value)
      end
      
    when Hash
      result = {}
      data.each do |key, value|
        result[prefix(prefix, key)] = value  
      end      
    end
    return result
  end
  
  #---
  
  def self.ensure(test, success_value = nil, failure_value = nil)
    success_value = (success_value ? success_value : test)
    failure_value = (failure_value ? failure_value : nil)
      
    if empty?(test)
      value = failure_value
    else
      value = success_value
    end
    return value
  end
  
  #---
  
  def self.ensure_value(value, failure_value = nil)
    return self.ensure(value, nil, failure_value)
  end
end
end
end
