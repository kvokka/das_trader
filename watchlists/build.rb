#!/usr/bin/env ruby

require 'csv'
require 'pathname'
require 'fileutils'

# Empty watchlist creation is a little fuck in DAS
# So let's create a template for it

#idk why, but DAS watchlists have to end with empty column
COLUMNS = ['Symbol', 'Tick', '% Change', 'Change', 'Last', 'Volume', 'RVOL', 'Exchange', 'UserNotes']
COLUMNS << nil

input_path = Pathname.new(ENV.fetch('INPUT_PATH', 'input'))
FileUtils.mkdir_p input_path

output_path = Pathname.new(ENV.fetch('OUTPUT_PATH', 'output'))
FileUtils.mkdir_p output_path

CSV.open(output_path.join('empty.csv'), "wb") do |csv|
  csv << COLUMNS
  100.times do
    csv << Array.new(COLUMNS.size)
  end
end

Dir[input_path.join('*')].each do |file|
  watchlist = File.basename(file, File.extname(file))
  csv_filename = watchlist + '.csv'
  loaded_symbols = {}

  CSV.open(output_path.join(csv_filename), "wb") do |csv|
    csv << COLUMNS
    File.open(file, 'r').each do |line|
      symbol, *user_notes = line.split

      # Remove extra characters for easier copy/paste
      symbol&.gsub!(/[^\p{Alnum} -]/, '')
      puts(%Q[===> Symbol #{symbol} was already loaded in watchlist #{watchlist}]) if loaded_symbols[symbol]
      loaded_symbols[symbol] = true if symbol

      # Remove empty comments
      user_notes = nil if user_notes.empty?

      csv << Array.new(COLUMNS.size).tap do |result|
        result[COLUMNS.index('Symbol')] = symbol&.upcase if COLUMNS.index('Symbol')
        result[COLUMNS.index('UserNotes')] = user_notes&.join(' ') if COLUMNS.index('UserNotes')
      end
    end
  end
end

