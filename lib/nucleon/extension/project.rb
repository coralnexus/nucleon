
module Nucleon
module Extension
class Project < Nucleon.plugin_class(:nucleon, :extension)
  
  def manager_plugin_provider(config)
    if config[:namespace] == :nucleon && config[:type] == :project
      if config[:directory] && provider = Nucleon::Plugin::Project.load_provider(config[:directory])
        return provider
      end
    end
    nil
  end
end
end
end
