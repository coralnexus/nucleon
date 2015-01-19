
nucleon_require(File.dirname(__FILE__), :git)

#---

module Nucleon
module Project
class Github < Git

  #-----------------------------------------------------------------------------
  # Project plugin interface

  def normalize(reload)
    if reference = delete(:reference, nil)
      myself.plugin_name = normalize_reference(reference)
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
      external_ip = Nucleon.ip_address
      internal_ip = get(:internal_ip, nil)

      if internal_ip && internal_ip.to_s != external_ip
        location = "#{external_ip}[#{internal_ip}]"
      else
        location = external_ip
      end

      key_id  = ENV['USER'] + '@' + location
      ssh_key = public_key_str

      if private_key && ssh_key
        deploy_keys = client.deploy_keys(plugin_name)
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
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def self.expand_url(path, editable = false)
    if path =~ /^[a-zA-Z0-9_\-\/]+$/
      if editable
        protocol  = 'git@'
        separator = ':'
      else
        protocol  = 'https://'
        separator = '/'
      end
      url = "#{protocol}github.com#{separator}" + path + '.git'
    else
      url = path
    end
    url
  end

  #---

  def verify_key
    Util::SSH.init_session('github.com', 'git', 22, private_key)
    Util::SSH.close('github.com', 'git')
  end
  protected :verify_key

  #---

  def normalize_reference(reference)
    reference.sub(/^(git\@|(https?|git)\:\/\/)[^\/\:]+(\/|\:)?/, '').sub(/\.git$/, '')
  end
  protected :normalize_reference
end
end
end
