# frozen_string_literal: true

# Patch das config file with user defines alerts in the latest watchlist
class AlertsCreator
  attr_reader :file_desc, :lines

  def initialize(all_watchlists)
    @file_desc, @lines = all_watchlists.max_by { |k, _v| k.updated_at }
    @lines = @lines.dup.select { |l| l.user_notes && l.symbol }
    config
  end

  def call
    print_greeting
    process_lines
    update_config
  end

  private

  def update_config
    File.open(ENV['DAS_CONFIG_CFG_PATH'], 'w') do |f|
      config.each { |l| f.write(l) }
    end
  end

  def process_lines
    lines.each do |line|
      alerts = line.user_notes.scan(/([ABLV]\s*([>|<]=?\s*\d+\.?\d*|=\s*\d+\.?\d*))/)
      next if alerts.empty?

      alert_name = "From #{@file_desc.name} #{line.symbol.upcase} - #{line.user_notes}"

      next if config.detect { |l| l =~ /#{alert_name}/ }

      add_alert alert_name: alert_name, symbol: line.symbol.upcase, alerts: alerts
    end
  end

  # It translate the alert to DAS digestable format.
  # Each alert is described with this pattern
  #
  #   B3500  means:
  # `B` - code of the field. {L: 'Last Price', B: 'L1 Bid', A: 'L1 Ask', V: 'Volume'}
  # `3` - comparison code. { 1 => '<', 2 => '<=', 3 => '=', 4 => '>', 5 => '>=' }
  # 500 - comparison value
  def add_alert(symbol:, alert_name:, alerts:)
    next_alert_id.tap do |id|
      config << "ALERT#{id}:SNDFILE:#{ENV['DAS_ALERT_SOUND_FILE_PATH']}\r\n"
      config << "ALERT#{id}:CONDST:#{raw_alerts(alerts: alerts)}\r\n"
      config << "ALERT#{id}:SEC:#{symbol},11,0\r\n"
      config << "ALERT#{id}:ALERTNAME:#{alert_name}\r\n"
    end
  end

  def raw_alerts(alerts:)
    alerts.map(&:first)
          .map do |a|
      a.gsub(/\s*/, '').sub(/<=/, '2').sub(/>=/, '5').sub(/=/, '3').sub(/</, '1').sub(/>/, '4')
    end.join(',')
  end

  def print_greeting
    puts <<~TEXT
      Add alerts from file #{@file_desc.name} updated at #{file_desc.updated_at}
      Backup config file saved in #{backup_file_name}
    TEXT
  end

  def config
    return @config if @config

    FileUtils.cp(ENV['DAS_CONFIG_CFG_PATH'], backup_file_name)
    @config = File.open(ENV['DAS_CONFIG_CFG_PATH'], 'r').readlines
  end

  def backup_file_name
    @backup_file_name ||= backup_path.join(Time.now.strftime('config_backup_%Y-%B-%d--%k-%M-%S.cfg.bak'))
  end

  def config_path
    @config_path ||= Pathname.new File.absolute_path(ENV['DAS_CONFIG_CFG_PATH'])
  end

  def backup_path
    @backup_path ||= Pathname.new FileUtils.mkdir_p(config_path.parent.join('backup')).last
  end

  def next_alert_id
    return @next_alert_id += 1 if @next_alert_id

    @next_alert_id = 0.yield_self do |result|
      config.each do |line|
        line.match(/\AALERT(\d+).*/)
        result = [result, Regexp.last_match(1).to_i].max
      end
      result + 1
    end
  end
end
