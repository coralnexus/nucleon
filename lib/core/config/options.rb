
module Nucleon
class Config
class Options
  
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  @@options = {}
  
  #---
  
  def self.contexts(contexts = [], hierarchy = [])
    contexts = [ 'all', contexts ].flatten
    
    unless hierarchy.is_a?(Array)
      hierarchy = ( ! Util::Data.empty?(hierarchy) ? [ hierarchy ].flatten : [] )
    end
    
    hierarchy.each do |group|  
      group_contexts = Util::Data.prefix(group, contexts)
      contexts       = [ contexts, group_contexts ].flatten
    end
    
    return contexts
  end
  
  #---
  
  def self.get(contexts, force = true)
    options = {}
    
    unless contexts.is_a?(Array)
      contexts = ( ! Util::Data.empty?(contexts) ? [ contexts ].flatten : [] )
    end
    contexts.each do |name|
      name = name.to_sym
      if @@options.has_key?(name)
        options = Util::Data.merge([ options, @@options[name] ], force)
      end
    end
    return options
  end
  
  #---
  
  def self.set(contexts, options, force = true)
    unless contexts.is_a?(Array)
      contexts = ( ! Util::Data.empty?(contexts) ? [ contexts ].flatten : [] )
    end
    contexts.each do |name|
      name = name.to_sym    
      current_options = ( @@options.has_key?(name) ? @@options[name] : {} )
      @@options[name] = Util::Data.merge([ current_options, Config.symbol_map(options) ], force)
    end  
  end
  
  #---
  
  def self.clear(contexts)
    unless contexts.is_a?(Array)
      contexts = [ contexts ]
    end
    contexts.each do |name|
      @@options.delete(name.to_sym)
    end
  end
end
end
end
