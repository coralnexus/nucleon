
module Nucleon
module Extension
class Project < Nucleon.plugin_class(:nucleon, :extension)

  def manager_plugin_provider(config)
    if config[:namespace] == :nucleon && config[:type] == :project
      if config[:directory]
        project_info = Nucleon::Plugin::Project.load_project_info(config[:directory])
        return project_info[:provider] unless project_info.empty?
      end
    end
    nil
  end
end
end
end
