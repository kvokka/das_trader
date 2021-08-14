class Das
  def self.instance
    @instance ||= new
  end

  def update!
    File.open(ENV['DAS_CONFIG_CFG_PATH'], 'w') do |f|
      config.each { |l| f.write(l) }
    end
  end

  def config
    return @config if @config

    FileUtils.cp(ENV['DAS_CONFIG_CFG_PATH'], backup_file_name)
    @config = File.open(ENV['DAS_CONFIG_CFG_PATH'], 'r').readlines
  end

  def backup_file_name
    @backup_file_name ||= backup_path.join(Time.now.strftime('config_backup_%Y-%B-%d--%k-%M-%S.cfg.bak'))
  end

  private

  def config_path
    @config_path ||= Pathname.new File.absolute_path(ENV['DAS_CONFIG_CFG_PATH'])
  end

  def backup_path
    @backup_path ||= Pathname.new FileUtils.mkdir_p(config_path.parent.join('backup')).last
  end
end
