
#-------------------------------------------------------------------------------
# Hash data type alterations

class Hash
  def search(search_key, options = {})
    config = Nucleon::Config.ensure(options)
    value  = nil
    
    recurse       = config.get(:recurse, false)
    recurse_level = config.get(:recurse_level, -1)
        
    self.each do |key, data|
      if key == search_key
        value = data
        
      elsif data.is_a?(Hash) && 
        recurse && (recurse_level == -1 || recurse_level > 0)
        
        recurse_level -= 1 unless recurse_level == -1
        value = value.search(search_key, 
          Nucleon::Config.new(config).set(:recurse_level, recurse_level)
        )
      end
      break unless value.nil?
    end
    return value
  end
end
