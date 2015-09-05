
module Nucleon
module Util
class Cache < Core

  @@cache_lock = Mutex.new

  #-----------------------------------------------------------------------------

  # This class already inherits much of what we need from the core config class.
  # Right now we just have to worry about persistence

  #-----------------------------------------------------------------------------
  # Constructor / Destructor

  def initialize(root_path, id, cache_dir = '.cache', force = true)
    super({}, {}, force)

    @cache_dir  = cache_dir
    @cache_root = File.join(root_path, cache_dir)
    FileUtils.mkdir_p(base_path) unless File.directory?(base_path)

    @cache_id         = id.to_sym
    @cache_translator = Nucleon.type_default(:nucleon, :translator)
    @cache_filename   = "#{id}.#{translator}"
    @cache_path       = File.join(@cache_root, @cache_filename)

    unless File.exist?(file)
      parser = Nucleon.translator({}, translator)
      Disk.write(file, parser.generate({}))
    end
    load
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def status
    @status
  end

  #---

  def base_path
    @cache_root
  end

  #---

  def directory_name
    @cache_dir
  end

  #---

  def id
    @cache_id
  end

  #---

  def translator
    @cache_translator
  end

  #---

  def file
    @cache_path
  end

  #---

  def get(keys, default = nil, format = false)
    result = super(keys, nil)

    if result.nil?
      load
      result = super(keys, nil)
    end
    result = filter(default, format) if result.nil?
    result
  end

  #---

  def set(keys, value, delete_nil = false)
    result = super
    save if initialized?
    result
  end

  #---

  def delete(keys, default = nil)
    result = super
    save if initialized?
    result
  end

  #---

  def clear
    result = super
    save if initialized?
    result
  end

  #-----------------------------------------------------------------------------
  # Operations

  def import_base(properties, options = {})
    config = Config.ensure(options)

    result = super
    save if initialized? && ! config.get(:no_save, false)
    result
  end

  #---

  def load
    success = false
    @status = 255

    @@cache_lock.synchronize do
      logger.info("Loading #{translator} translated cache from #{file}")

      parser = Nucleon.translator({}, translator)
      raw    = Disk.read(file)

      if parser && raw && ! raw.empty?
        logger.debug("Cache file contents: #{raw}")
        parse_properties = Data.hash(parser.parse(raw))

        Nucleon.remove_plugin(parser)

        import(parse_properties, { :no_save => true }) unless parse_properties.empty?
        success = true
        @status = Nucleon.code.success
      end
    end
    success
  end

  #---

  def save
    success = false
    @status = 255

    @@cache_lock.synchronize do
      if renderer = Nucleon.translator({}, translator)
        rendering = renderer.generate(export)

        Nucleon.remove_plugin(renderer)

        if Disk.write(file, rendering)
          success = true
          @status = Nucleon.code.success
        end
      end
    end
    success
  end
end
end
end
