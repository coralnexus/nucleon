
# Should be included via include
#
# include Mixin::Settings
#

module Nucleon
module Mixin
module Settings
  
  def settings(name)
    return get_hash([ :settings, name ])
  end
    
  #---

  def set_settings(name, settings = {})
    return set([ :settings, name ], settings)
  end
    
  #---

  def delete_settings(name)
    return delete([ :settings, name ])
  end
    
  #---
   
  def setting(name, key, default = '', format = false)
    return get([ :settings, name, key ], default, format)
  end
     
  #---

  def set_setting(name, key, value = '')
    return set([ :settings, name, key ], value)
  end
     
  #---

  def delete_setting(name, key)
    return delete([ :settings, name, key ])
  end
end
end
end
