# frozen_string_literal: true

require 'csv'

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
    # Note that on Windows (NTFS), returns creation time (birth time).
    Dir[path.join('*')].each do |file|
      file_desc(file).tap do |file_desc|
        File.open(file, 'r').each do |line|
          loaded[file_desc] << build_line(line, file_desc.watchlist)
        end
      end
    end
    loaded.select { |k, _| k }
  end

  private

  def file_desc(file)
    OpenStruct.new({
                     name: File.basename(file, File.extname(file)),
                     updated_at: File.ctime(file)
                   })
  end

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
