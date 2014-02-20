
module Nucleon
module Util
class Git < ::Grit::Repo

  #-----------------------------------------------------------------------------
  # Constructor / Destructor

  def initialize(path, options = {})
    epath   = File.expand_path(path)
    git_dir = File.join(epath, '.git')
    
    @bare = (options[:is_bare] ? true : false)
    
    Grit.debug = true if Nucleon.log_level == :debug
    
    if File.exist?(git_dir)
      self.working_dir = epath
      
      if File.directory?(git_dir)
        self.path = git_dir
      else
        git_dir = Util::Disk.read(git_dir)
        unless git_dir.nil?
          git_dir = git_dir.gsub(/^gitdir\:\s*/, '').strip
          self.path = git_dir if File.directory?(git_dir)
        end
      end
      
    elsif File.directory?(epath) && (options[:is_bare] || (epath =~ /\.git$/ && File.exist?(File.join(epath, 'HEAD'))))
      self.path = epath
      @bare = true
      
    else
      self.path = git_dir
    end
    
    self.git = ::Grit::Git.new(self.path)
    self.git.work_tree = epath
  end
end
end
end
