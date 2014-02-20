
module Nucleon
module Util
class Package
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize(options = {})
    if options.is_a?(String)
      @data = Config.new
      decode(options)  
    else
      @data = Config.ensure(options)
    end
  end
      
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  attr_reader :data
 
  #-----------------------------------------------------------------------------
  # Operations

  def encode
    Base64.encode64(Data.to_json(data.export, false))
  end
      
  def decode(encoded_string)
    data.import(Data.symbol_map(Data.parse_json(Base64.decode64(encoded_string))))  
  end
  
  #---
  
  def add_file(file, target_path = nil, perm = 0600)    
    target_path = file if target_path.nil?
    file        = File.expand_path(file)
    
    if File.exists?(file)
      content = Disk.read(file)
      data.set([ :files, target_path ], { :perm => perm, :content => content }) if content
    end
    self
  end
  
  #---
  
  def add_files(base_path, file_glob, target_path = nil, perm = 0600)
    target_path = base_path if target_path.nil?
    curr_dir    = Dir.pwd
    
    Dir.chdir(File.expand_path(base_path))
    Dir.glob(file_glob.gsub(/^[\/\\]+/, '')) do |file|
      content = Disk.read(file)
      
      if content
        data.set([ :dir, target_path, file ], { :perm => perm, :content => content })
      end
    end
    Dir.chdir(curr_dir)
    self      
  end
  
  #---
  
  def extract(base_path)
    success = true
    
    data.get_hash(:files).each do |target_path, info|
      file    = File.join(base_path.to_s, target_path.to_s)
      perm    = info[:perm]
      content = info[:content]
      
      FileUtils.mkdir_p(File.dirname(file))      
      success = false unless Disk.write(file, content) && File.chmod(perm, file)
    end
    
    data.get_hash(:dir).each do |target_path, files|
      files.each do |file, info|
        file    = File.join(base_path.to_s, target_path.to_s, file.to_s)
        perm    = info[:perm]
        content = info[:content]
        
        FileUtils.mkdir_p(File.dirname(file))
        success = false unless Disk.write(file, content) && File.chmod(perm, file)
      end      
    end
    success
  end
end
end
end
