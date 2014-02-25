
nucleon_require(File.dirname(__FILE__), :git)

#---

module Nucleon
module Project
class Github < Git
 
  #-----------------------------------------------------------------------------
  # Project plugin interface
 
  def normalize(reload)    
    if reference = delete(:reference, nil)
      myself.plugin_name = reference
    else
      if url = get(:url, nil)
        myself.plugin_name = url
        set(:url, myself.class.expand_url(url, get(:ssh, false)))
      end  
    end    
    super
  end
  
  #---
  
  def set_connection
    require 'octokit'
    
    @client = Octokit::Client.new :netrc => true
    @client.login
  end
  
  #-----------------------------------------------------------------------------
  # Property accessor / modifiers
  
  def client
    set_connection unless @client
    @client
  end
  
  #-----------------------------------------------------------------------------
  # Project operations
  
  def init_auth
    super do
      key_id  = ENV['USER'] + '@' + lookup(:ipaddress)
      ssh_key = public_key_str
      
      if private_key && ssh_key
        begin
          deploy_keys = client.deploy_keys(myself.plugin_name)
          github_id   = nil
          keys_match  = true
                   
          deploy_keys.each do |key_resource|
            if key_resource.title == key_id
              github_id  = key_resource.id              
              keys_match = false if key_resource.key != ssh_key
              break
            end  
          end
                     
          client.remove_deploy_key(myself.plugin_name, github_id) if github_id && ! keys_match
          client.add_deploy_key(myself.plugin_name, key_id, ssh_key)
          verify_key
          
                  
        rescue Exception => error
          logger.error(error.inspect)
          logger.error(error.message)
          logger.error(Util::Data.to_yaml(error.backtrace))

          ui.error(error.message, { :prefix => false }) if error.message
        end
      end
    end  
  end
     
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.expand_url(path, editable = false)
    if editable
      protocol  = 'git@'
      separator = ':'
    else
      protocol  = 'https://'
      separator = '/'
    end
    return "#{protocol}github.com#{separator}" + path + '.git'  
  end
  
  #---
  
  def verify_key
    Util::SSH.init_session('github.com', 'git', 22, private_key)
    Util::SSH.close('github.com', 'git')
  end
  protected :verify_key
end
end
end
