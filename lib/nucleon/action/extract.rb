
module Nucleon
module Action
class Extract < Nucleon.plugin_class(:nucleon, :action)
  
  #-----------------------------------------------------------------------------
  # Info
  
  def self.describe
    super(nil, :extract, -50)
  end
  
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do
      codes :extract_failure
         
      register :path, :str, nil do |value|
        unless File.directory?(value)
          warn('nucleon.action.extract.errors.path', { :value => value })
          next false
        end
        true
      end
      register :encoded, :str, nil do |value|
        @package = Util::Package.new(value)
        if @package.data.export.empty?
          warn('nucleon.action.extract.errors.encoded', { :value => value })
          next false  
        end
        true
      end
    end
  end
  
  #---
  
  def arguments
    [ :path, :encoded ]
  end
 
  #-----------------------------------------------------------------------------
  # Operations
  
  def execute
    super do
      unless @package.extract(settings[:path])
        myself.status = code.extract_failure
      end
    end
  end
end
end
end
