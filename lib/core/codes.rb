
module Nucleon
class Codes
  
  #-----------------------------------------------------------------------------
  # Code index
  
  @@registry     = {}
  @@status_index = {}
  @@next_code    = 0
  
  #---
  
  def self.registry
    @@registry
  end
  
  #---
  
  def self.status_index
    @@status_index
  end
  
  #---
  
  def self.index(status_code = nil)
    if status_code.nil? || ! status_code.integer?
      @@status_index
    else
      status_code = status_code.to_i
          
      if @@status_index.has_key?(status_code)
        @@status_index[status_code]
      else
        @@status_index[registry[:unknown_status]]
      end  
    end    
  end
  
  #---
  
  def self.render_index(status_code = nil)
    output = "Status index:\n"
    @@status_index.each do |code, name|
      name = name.gsub(/_/, ' ').capitalize
      
      if ! status_code.nil? && status_code == code
        output << sprintf(" [ %3i ] - %s\n", code, name)
      else
        output << sprintf("   %3i   - %s\n", code, name)
      end      
    end
    output << "\n"
    output
  end
  
  #-----------------------------------------------------------------------------
  # Code construction
  
  def self.code(name)
    name = name.to_sym
    
    unless registry.has_key?(name)
      status_code = @@next_code    
      @@next_code = @@next_code + 1
    
      # TODO: Add more information to the index (like a help message)
      @@registry[name]            = status_code
      @@status_index[status_code] = name.to_s
    end
  end
  
  #---
  
  def self.codes(*codes)
    codes.each do |name|
      code(name)
    end
  end

  #-----------------------------------------------------------------------------
  # Return status codes on demand
  
  def [](name)
    name = name.to_sym
    
    if @@registry.has_key?(name)
      @@registry[name]  
    else
      @@registry[:unknown_status]
    end
  end
  
  #---
 
  def method_missing(method, *args, &block)
    self[method]
  end
  
  #-----------------------------------------------------------------------------
  # Core status codes
  
  code(:success) # This must be added first (needs to be 0)
  code(:help_wanted)
  code(:unknown_status)
  
  code(:action_unprocessed)
  code(:batch_error)
  
  code(:validation_failed)
  code(:access_denied) 
end
end
