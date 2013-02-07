module Eye::Dsl::Main
  attr_accessor :parsed_config, :parsed_options, :parsed_filename

  def application(name, &block)
    Eye::Dsl.debug "=> app: #{name}"
    @parsed_config ||= {}
    opts = Eye::Dsl::ApplicationOpts.new(name)
    opts.instance_eval(&block)
    @parsed_config[name.to_s] = opts.config if opts.config
    Eye::Dsl.debug "<= app: #{name}"
  end

  alias :app :application 

  def load(glob = '')
    saved_parsed_filename = self.parsed_filename

    return if glob.blank?
    require 'pathname'

    real_filename = parsed_filename && File.symlink?(parsed_filename) ? File.readlink(parsed_filename) : parsed_filename
    dirname = File.dirname(real_filename) rescue nil
    mask = Pathname.new(glob).expand_path(dirname).to_s
    Dir[mask].each do |path|
      Eye::Dsl.debug "=> load #{path}"

      self.parsed_filename = path

      res = Kernel.load(path)
      Eye.info "load: subload #{path} (#{res})"

      Eye::Dsl.debug "<= load #{path}"
    end

  ensure
    self.parsed_filename = saved_parsed_filename
  end

  def logger=(log_path)
    @parsed_options ||= {}
    @parsed_options[:logger] = log_path
  end
  
  def logger_level=(log_level)
    @parsed_options ||= {}
    @parsed_options[:logger_level] = log_level
  end
end
