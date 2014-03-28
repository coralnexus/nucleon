
module Nucleon
module Action
class Extract < Nucleon.plugin_class(:action)
 
  #-----------------------------------------------------------------------------
  # Settings
  
  def configure
    super do
      codes :extract_failure
         
      register :path, :str, nil do |value|
        unless File.directory?(value)
          warn('nucleon.actions.extract.errors.path', { :value => value })
          next false
        end
        true
      end
      register :encoded, :str, nil do |value|
        @package = Util::Package.new(value)
        if @package.data.export.empty?
          warn('nucleon.actions.extract.errors.encoded', { :value => value })
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
