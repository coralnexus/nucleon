
module Nucleon
module Util
class Git

  #-----------------------------------------------------------------------------
  # Git repo loader
  
  def self.load(path, options = {})
    epath   = File.expand_path(path)
    git_dir = File.join(epath, '.git')
    git     = nil
    
    begin
      if File.exist?(git_dir)
        if File.directory?(git_dir)
          git = Rugged::Repository.new(git_dir)
        else
          # TODO: Find out if this is actually necessary with Rugged / LibGit2
          git_dir = Util::Disk.read(git_dir)
          unless git_dir.nil?
            git_dir = git_dir.gsub(/^gitdir\:\s*/, '').strip
          
            if File.directory?(git_dir)
              git         = Rugged::Repository.new(git_dir)
              git.workdir = epath  
            end
          end
        end      
      elsif File.directory?(epath) && (options[:bare] || (epath =~ /\.git$/ && File.exist?(File.join(epath, 'HEAD'))))
        git = Rugged::Repository.bare(epath)
      end
    rescue
    end
    
    if git.nil? && options[:create]
      FileUtils.mkdir_p(epath) unless File.directory?(epath)
      if options[:bare]
        git = Rugged::Repository.init_at(epath, :bare)
      else
        git = Rugged::Repository.init_at(epath)
      end
    end        
    git
  end
end
end
end
