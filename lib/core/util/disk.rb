
module Nucleon
module Util
class Disk
  
  #-----------------------------------------------------------------------------
  # Properties
 
  @@separator   = false
  @@description = ''
  
  @@file_lock   = Mutex.new
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.exists?(file)
    return ::File.exists?(::File.expand_path(file))  
  end
  
  #---
  
  def self.filename(file_name)
    return ( file_name.is_a?(Array) ? file_name.join(::File::SEPARATOR) : file_name.to_s )
  end
  
  #---
  
  def self.read(file_name, options = {})
    result = nil
    options[:mode] = ( options[:mode] ? options[:mode] : 'r' )
    
    @@file_lock.synchronize do
      begin
        if file = ::File.open(file_name, options[:mode])
          result = file.read
          file.close
        end
      rescue # TODO: Only catch error if file is not found.
      end
    end
    return result
  end
  
  #---
  
  def self.write(file_name, data, options = {})
    result = nil
    options[:mode] = ( options[:mode] ? options[:mode] : 'w' )
        
    @@file_lock.synchronize do
      if file = ::File.open(file_name, options[:mode])
        result = file.write(data)
        file.close
      end
    end
    return result
  end
  
  #---
  
  def self.delete(file_path)
    result = nil
    @@file_lock.synchronize do
      result = ::File.delete(file_path)
    end
    result
  end
  
  #---
  
  def self.log(data, options = {})
    reset = ( options[:file_name] || options[:mode] )
      
    @@file_lock.synchronize do      
      if file = ::File.open(( options[:file_name] ? options[:file_name] : 'log.txt' ), options[:mode]) 
        file.write("--------------------------------------\n") if @@separator
        file.write("#{@@description}\n") if @@description       
        file.write("#{data}\n")
        file.close
      end
    end
  end
end
end
end
