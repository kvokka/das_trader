# frozen_string_literal: true

require 'csv'
require 'pathname'
require 'fileutils'

# Load and parse provided text files
class CsvLoader
  # One parsed line representation
  class Line
    attr_reader :symbol, :user_notes

    def initialize(symbol:, user_notes: nil)
      @symbol = symbol
      @user_notes = user_notes&.join ' '
    end

    def <=>(other)
      symbol.to_s <=> other.to_s
    end

    def ==(other)
      symbol == other
    end
  end

  attr_reader :path, :loaded

  def initialize(path)
    @path = path
    @loaded = Hash.new { |h, k| h[k] = [] }
  end

  def call
    Dir[path.join('*')].each do |file|
      watchlist = File.basename(file, File.extname(file))

      File.open(file, 'r').each do |line|
        loaded[watchlist] << build_line(line, watchlist)
      end
    end
    loaded
  end

  private

  def build_line(line, watchlist)
    symbol, *user_notes = line.split

    # Remove extra characters for easier copy/paste
    symbol&.gsub!(/[^\p{Alnum} -]/, '')

    if symbol && loaded[watchlist].detect { |e| e == symbol }
      puts(%(===> Symbol #{symbol} was already loaded in watchlist #{watchlist}))
    end

    # Remove empty comments
    user_notes = nil if user_notes.empty?

    Line.new(symbol: symbol, user_notes: user_notes)
  end
end
