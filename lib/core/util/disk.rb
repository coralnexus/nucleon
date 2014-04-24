
module Nucleon
module Util
class Disk
  
  #-----------------------------------------------------------------------------
  # Properties
 
  @@files = {}
  
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
  
  def self.open(file_name, options = {}, reset = false)
    mode          = options[:mode].to_s
    
    @@separator   = ( options[:separator] ? options[:separator] : false )
    @@description = ( options[:description] ? options[:description] : '' )
    
    if @@files.has_key?(file_name) && ! reset
      reset = true if ! mode.empty? && mode != @@files[file_name][:mode]
    end
    
    if ! @@files.has_key?(file_name) || ! @@files[file_name][:file] || reset
      @@files[file_name][:file].close if @@files[file_name] && @@files[file_name][:file]
      unless mode.empty? || ( mode == 'r' && ! ::File.exists?(file_name) )
        @@files[file_name] = {
          :file => ::File.open(file_name, mode),
          :mode => mode,
        }
      end
    end
    return nil unless @@files[file_name]
    return @@files[file_name][:file]
  end
  
  #---
  
  def self.read(file_name, options = {})
    result = nil
    options[:mode] = ( options[:mode] ? options[:mode] : 'r' )
    
    @@file_lock.synchronize do
      if file = open(file_name, options)
        file.pos = 0 if options[:mode] == 'r'
        result = file.read
      end
    end
    return result
  end
  
  #---
  
  def self.write(file_name, data, options = {})
    options[:mode] = ( options[:mode] ? options[:mode] : 'w' )
    result         = nil
    
    @@file_lock.synchronize do
      if file = open(file_name, options)
        file.pos = 0 if options[:mode] == 'w'
        result = file.write(data)
        begin
          file.flush
        rescue # In case the file is already closed
        end
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
      if file = open(( options[:file_name] ? options[:file_name] : 'log.txt' ), options, reset)   
        file.write("--------------------------------------\n") if @@separator
        file.write("#{@@description}\n") if @@description       
        file.write("#{data}\n")
      end
    end
  end
  
  #---
  
  def self.close(file_names = [])
    file_names = @@files.keys unless file_names && ! file_names.empty?
    
    unless file_names.is_a?(Array)
      file_names = [ file_names ]
    end
    
    file_names.each do |file_name|
      @@file_lock.synchronize do
        @@files[file_name][:file].close if @@files[file_name] && @@files[file_name][:file]
        @@files.delete(file_name)
      end
    end
  end
end
end
end
