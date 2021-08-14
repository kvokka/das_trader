# frozen_string_literal: true

require 'csv'
require 'finviz'

require_relative 'virtual_watchlists_loader'

# Load and parse provided text files
class Loader
  # One parsed line representation
  class Line
    attr_reader :symbol, :raw_user_notes

    def initialize(symbol:, raw_user_notes: [])
      @symbol, @raw_user_notes = symbol&.downcase, raw_user_notes
    end

    def <=>(other)
      symbol.to_s <=> other.to_s
    end

    def ==(other)
      symbol == other
    end

    def user_notes
      return nil if @raw_user_notes.empty?

      raw_user_notes.join ' '
    end
  end

  NO_FINVIZ_DATA = ['NoFinvizData'].freeze
  MONTHS = [nil, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].freeze
  WEEK_BEFORE = Date.today - 7
  WEEK_AFTER = Date.today + 7

  class << self
    def loaded
      @loaded ||= Hash.new { |h, k| h[k] = [] }
    end
  end

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def call
    load_real_watchlists
    VirtualWatchlistsLoader.load
    add_fundamental_user_notes
    loaded.select { |k, _| k }
  end

  private

  def loaded
    self.class.loaded
  end

  def load_real_watchlists
    # Note that on Windows (NTFS), returns creation time (birth time).
    Dir[path.join('*')].each do |file|
      file_desc(file).tap do |file_desc|
        File.open(file, 'r').each do |line|
          loaded[file_desc] << build_line(line, file_desc.watchlist)
        end
      end
    end
  end

  def file_desc(file)
    OpenStruct.new({
                     name: File.basename(file, File.extname(file)),
                     updated_at: File.ctime(file)
                   })
  end

  def build_line(line, watchlist)
    symbol, *raw_user_notes = line.split

    # Remove extra characters for easier copy/paste
    symbol&.gsub!(/[^\p{Alnum} -]/, '')

    if symbol && loaded[watchlist].detect { |e| e == symbol }
      puts(%(===> Symbol #{symbol} was already loaded in watchlist #{watchlist}))
    end

    Line.new(symbol: symbol, raw_user_notes: raw_user_notes)
  end

  def add_fundamental_user_notes
    each_loaded_line do |line|
      fundamentals = finviz_data.public_send(line.symbol).yield_self do |quote|
        next NO_FINVIZ_DATA unless quote

        [].tap do |result|
          result << "Cap:#{quote.stats["Market Cap"]}"
          result << "ATR:#{quote.stats["ATR"]}"
          result << "Float:#{quote.stats["Shs Float"]}"
          result << calc_earnings_line(quote)
          result << "SrtFloat:#{quote.stats["Short Float"]}" if quote.stats["Short Float"].present?
          result << "TargetP:#{quote.stats["TargetPrice"]}" if quote.stats["TargetPrice"].present?
        end
      end

      line.raw_user_notes << fundamentals.compact.join(',')
    end
  end

  def finviz_data
    @finviz_data ||= begin
      tickers = Set.new.tap do |s|
        each_loaded_line do |line|
          s << line.symbol
        end
      end

      Finviz.quotes tickers: tickers
    end
  end

  # not optimal performance, but for array of this size who cares?
  def each_loaded_line
    loaded.each_value do |lines|
      lines.each do |line|
        yield(line) if line.symbol
      end
    end
  end

  def calc_earnings_line(quote)
    month, date, *_ = quote.stats["Earnings"].to_s.split(' ')

    return unless date

    range = Date.new(
        WEEK_BEFORE.year,WEEK_BEFORE.month,WEEK_BEFORE.day
      )..Date.new(
        WEEK_AFTER.year,WEEK_AFTER.month,WEEK_AFTER.day
      )

    return unless range.include?(Date.new(WEEK_AFTER.year, MONTHS.index(month), date.to_i))

    "Earnings:#{quote.stats["Earnings"]}"
  end
end
