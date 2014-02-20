
module Nucleon
    
  #-----------------------------------------------------------------------------
  # Core plugin type facade
  
  def self.extension(provider)
    plugin(:extension, provider, {})
  end
  
  #---
  
  def self.configuration(options, provider = nil)
    plugin(:configuration, provider, options)
  end
  
  def self.configurations(data, build_hash = false, keep_array = false)
    plugins(:configuration, data, build_hash, keep_array)
  end
  
  #---
  
  def self.action(provider, options)
    plugin(:action, provider, options)
  end
  
  def self.action_config(provider)
    action(provider, { :settings => {}, :quiet => true }).configure
  end
  
  def self.actions(data, build_hash = false, keep_array = false)
    plugins(:action, data, build_hash, keep_array)  
  end
  
  def self.action_run(provider, options = {}, quiet = true)
    Plugin::Action.exec(provider, options, quiet)
  end
  
  def self.action_cli(provider, args = [], quiet = false)
    Plugin::Action.exec_cli(provider, args, quiet)
  end
  
  #---
  
  def self.project(options, provider = nil)
    plugin(:project, provider, options)
  end
  
  def self.projects(data, build_hash = false, keep_array = false)
    plugins(:project, data, build_hash, keep_array)
  end
   
  #-----------------------------------------------------------------------------
  # Cluster plugin type facade
   
  def self.network(name, options = {}, provider = nil)
    plugin(:network, provider, Config.ensure(options).import({ :name => name }))
  end
  
  def self.networks(data, build_hash = false, keep_array = false)
    plugins(:network, data, build_hash, keep_array)
  end
   
  #---
  
  def self.node(name, options = {}, provider = nil)
    plugin(:node, provider, Config.ensure(options).import({ :name => name }))
  end
  
  def self.nodes(data, build_hash = false, keep_array = false)
    plugins(:node, data, build_hash, keep_array)
  end
  
  #---
  
  def self.provisioner(options, provider = nil)
    plugin(:provisioner, provider, options)
  end
  
  #---
  
  def self.provisioners(data, build_hash = false, keep_array = false)
    plugins(:provisioner, data, build_hash, keep_array)
  end
  
  #---
  
  def self.command(options, provider = nil)
    plugin(:command, provider, options)
  end
  
  def self.commands(data, build_hash = false, keep_array = false)
    plugins(:command, data, build_hash, keep_array)
  end
    
  #-----------------------------------------------------------------------------
  # Utility plugin type facade
  
  def self.event(options, provider = nil)
    plugin(:event, provider, options)
  end
  
  def self.events(data, build_hash = false, keep_array = false)
    plugins(:event, data, build_hash, keep_array)
  end
  
  #---
  
  def self.template(options, provider = nil)
    plugin(:template, provider, options)
  end
  
  def self.templates(data, build_hash = false, keep_array = false)
    plugins(:template, data, build_hash, keep_array)
  end
   
  #---
  
  def self.translator(options, provider = nil)
    plugin(:translator, provider, options)
  end
  
  def self.translators(data, build_hash = false, keep_array = false)
    plugins(:translator, data, build_hash, keep_array)
  end
end
