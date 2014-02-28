
module CORL
module Util
class SSH < Nucleon::Core
  
  #-----------------------------------------------------------------------------
  # User key home
  
  @@key_path = nil
  
  #---
  
  def self.key_path
    unless @@key_path
      home_path  = ( ENV['USER'] == 'root' ? '/root' : ENV['HOME'] ) # In case we are using sudo
      @@key_path = File.join(home_path, '.ssh')
    
      FileUtils.mkdir(@@key_path) unless File.directory?(@@key_path)
    end
    @@key_path
  end
  
  #-----------------------------------------------------------------------------
  # Instance generators
  
  def self.generate(options = {})
    config = Config.ensure(options)
    
    private_key  = config.get(:private_key, nil)
    original_key = nil
    key_comment  = config.get(:comment, '')    
    
    if private_key.nil?
      key_type    = config.get(:type, "RSA")
      key_bits    = config.get(:bits, 2048)
      passphrase  = config.get(:passphrase, nil)
    
      key_data = SSHKey.generate(
        :type       => key_type, 
        :bits       => key_bits, 
        :comment    => key_comment, 
        :passphrase => passphrase
      )
      is_new = true
      
    else
      if private_key.include?('PRIVATE KEY')
        original_key = private_key   
      else
        original_key = Disk.read(private_key)
      end
      
      key_data = SSHKey.new(original_key, :comment => key_comment) if original_key
      is_new   = false
    end
    
    return nil unless key_data && ! key_data.ssh_public_key.empty?
    Keypair.new(key_data, is_new, original_key)
  end
  
  #-----------------------------------------------------------------------------
  # Checks
  
  def self.valid?(public_ssh_key)
    SSHKey.valid_ssh_public_key?(public_ssh_key)
  end
  
  #-----------------------------------------------------------------------------
  # Keypair interface
    
  class Keypair
    attr_reader :type, :private_key, :encrypted_key, :public_key, :ssh_key
    
    def initialize(key_data, is_new, original_key)
      @type          = key_data.type
      @private_key   = key_data.private_key
      @encrypted_key = is_new ? key_data.encrypted_private_key : original_key
      @public_key    = key_data.public_key
      @ssh_key       = key_data.ssh_public_key
    end
    
    #---
    
    def store(key_path = nil, key_base = 'id')
      key_path         = SSH.key_path if key_path.nil?
      private_key_file = File.join(key_path, "#{key_base}_#{type.downcase}")
      public_key_file  = File.join(key_path, "#{key_base}_#{type.downcase}.pub")
      
      private_success = Disk.write(private_key_file, encrypted_key)
      FileUtils.chmod(0600, private_key_file) if private_success
      
      public_success  = Disk.write(public_key_file, ssh_key)
      
      if private_success && public_success
        return { :private_key => private_key_file, :public_key => public_key_file }
      end
      false
    end
  end
  
  #-----------------------------------------------------------------------------
  # SSH Execution interface
  
  @@sessions = {}
  
  #---
  
  def self.session_id(hostname, user)
    "#{hostname}-#{user}"  
  end
  
  #---
  
  def self.session(hostname, user, port = 22, private_key = nil, reset = false, options = {})
    require 'net/ssh'
    
    ssh_options = Config.new({
      :user_known_hosts_file => [ File.join(key_path, 'known_hosts'), File.join(key_path, 'known_hosts2') ],
      :key_data              => [],
      :keys_only             => false,
      :auth_methods          => [ 'publickey' ],
      :paranoid              => :very
    }).import(options)
    
    ssh_options[:port] = port
    ssh_options[:keys] = private_key.nil? ? [] : [ private_key ]
    
    session_id = session_id(hostname, user)
    
    if reset || ! @@sessions.has_key?(session_id)
      @@sessions[session_id] = Net::SSH.start(hostname, user, ssh_options.export)
    end
    yield(@@sessions[session_id]) if block_given? && @@sessions[session_id]
    @@sessions[session_id] 
  end
  
  def self.init_session(hostname, user, port = 22, private_key = nil, options = {})
    session(hostname, user, port, private_key, true, options)  
  end
  
  #---
  
  def self.close(hostname = nil, user = nil)
    if hostname && user.nil? # Assume we entered a session id
      if @@sessions.has_key?(hostname)
        @@sessions[hostname].close
        @@sessions.delete(hostname)  
      end
      
    elsif hostname && user # Generate session id from args
      session_id = session_id(hostname, user)
      
      if @@sessions.has_key?(session_id)
        @@sessions[session_id].close
        @@sessions.delete(session_id)  
      end
      
    else # Close all connections
      @@sessions.keys.each do |id|
        @@sessions[id].close
        @@sessions.delete(id)      
      end
    end
  end
  
  #---
  
  def self.exec(hostname, user, commands)
    results = []
        
    begin
      session(hostname, user) do |ssh|
        Data.array(commands).each do |command|
          command = command.flatten.join(' ') if command.is_a?(Array)
          command = command.to_s
          result  = Shell::Result.new(command)
              
          ssh.open_channel do |ssh_channel|
            ssh_channel.request_pty
            ssh_channel.exec(command) do |channel, success|
              unless success
                raise "Could not execute command: #{command.inspect}"
              end

              channel.on_data do |ch, data|
                result.append_output(data)
                yield(:output, command, data) if block_given?
              end

              channel.on_extended_data do |ch, type, data|
                next unless type == 1
                result.append_errors(data)
                yield(:error, command, data) if block_given?
              end

              channel.on_request('exit-status') do |ch, data|
                result.status = data.read_long
              end

              channel.on_request('exit-signal') do |ch, data|
                result.status = 255
              end
            end
          end
          ssh.loop              
          results << result
        end
      end
    rescue Net::SSH::HostKeyMismatch => error
      error.remember_host!
      sleep 0.2
      retry
    end
    results  
  end
  
  #---
  
  def self.download(hostname, user, remote_path, local_path, options = {})
    config = Config.ensure(options)
    
    require 'net/scp'
    
    # Accepted options:
    # * :recursive - the +remote+ parameter refers to a remote directory, which
    # should be downloaded to a new directory named +local+ on the local
    # machine.
    # * :preserve - the atime and mtime of the file should be preserved.
    # * :verbose - the process should result in verbose output on the server
    # end (useful for debugging).
    #
    config.init(:recursive, true)
    config.init(:preserve, true)
    config.init(:verbose, true)
    
    blocking = config.delete(:blocking, true)
    
    session(hostname, user) do |ssh|
      if blocking
        ssh.scp.download!(remote_path, local_path, config.export) do |ch, name, received, total|
          yield(name, received, total) if block_given?
        end
      else
        ssh.scp.download(remote_path, local_path, config.export)
      end
    end
  end
  
  #---
  
  def self.upload(hostname, user, local_path, remote_path, options = {})
    config = Config.ensure(options)
    
    require 'net/scp'
    
    # Accepted options:
    # * :recursive - the +local+ parameter refers to a local directory, which
    # should be uploaded to a new directory named +remote+ on the remote
    # server.
    # * :preserve - the atime and mtime of the file should be preserved.
    # * :verbose - the process should result in verbose output on the server
    # end (useful for debugging).
    # * :chunk_size - the size of each "chunk" that should be sent. Defaults
    # to 2048. Changing this value may improve throughput at the expense
    # of decreasing interactivity.
    #
    config.init(:recursive, true)
    config.init(:preserve, true)
    config.init(:verbose, true)
    config.init(:chunk_size, 2048)
    
    blocking = config.delete(:blocking, true)
    
    session(hostname, user) do |ssh|
      if blocking
        ssh.scp.upload!(local_path, remote_path, config.export) do |ch, name, sent, total|
          yield(name, sent, total) if block_given?
        end
      else
        ssh.scp.upload(local_path, remote_path, config.export)
      end
    end
  end
  
  #---
  
  #
  # Inspired by vagrant ssh implementation
  #
  # See: https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/util/ssh.rb
  #
  
  def self.terminal(hostname, user, options = {})
    config   = Config.ensure(options)
    ssh_path = nucleon_locate("ssh")
    
    raise Errors::SSHUnavailable unless ssh_path
    
    port         = config.get(:port, 22)
    private_keys = config.get(:private_keys, File.join(ENV['HOME'], '.ssh', 'id_rsa'))
    
    command_options = [
      "#{user}@#{hostname}",
      "-p", port.to_s,
      "-o", "Compression=yes",
      "-o", "DSAAuthentication=yes",
      "-o", "LogLevel=FATAL",
      "-o", "StrictHostKeyChecking=no",
      "-o", "UserKnownHostsFile=/dev/null",
      "-o", "IdentitiesOnly=yes"
    ]

    Util::Data.array(private_keys).each do |path|
      command_options += [ "-i", File.expand_path(path) ]
    end
    
    if config.get(:forward_x11, false)
      command_options += [
        "-o", "ForwardX11=yes",
        "-o", "ForwardX11Trusted=yes"
      ]
    end

    command_options += [ "-o", "ProxyCommand=#{config[:proxy_command]}" ] if config.get(:proxy_command, false)
    command_options += [ "-o", "ForwardAgent=yes" ] if config.get(:forward_agent, false)
    
    command_options.concat(Util::Data.array(config[:extra_args])) if config.get(:extra_args, false)

    #---

    logger.info("Executing SSH in subprocess: #{command_options.inspect}")
    
    process = ChildProcess.build('ssh', *command_options)
    process.io.inherit!
    
    process.start
    process.wait
    process.exit_code
  end
end
end
end
