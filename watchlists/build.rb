#!/usr/bin/env ruby

require_relative 'loader'

# Empty watchlist creation is a little fuck in DAS
# So let's create a template for it

#idk why, but DAS watchlists have to end with empty column
COLUMNS = ['Symbol', 'Tick', '% Change', 'Change', 'Last', 'Volume', 'RVOL', 'Exchange', 'UserNotes']
COLUMNS << nil

FileUtils.mkdir_p(INPUT_PATH = Pathname.new(ENV.fetch('INPUT_PATH', 'input')))
FileUtils.mkdir_p(OUTPUT_PATH = Pathname.new(ENV.fetch('OUTPUT_PATH', 'output')))

def generate_csv(watchlist)
  csv_filename = watchlist + '.csv'
  CSV.open(OUTPUT_PATH.join(csv_filename), "wb") do |csv|
    csv << COLUMNS
    yield csv
  end
end

generate_csv('empty') {|csv| 100.times{ csv << Array.new(COLUMNS.size) }}

CsvLoader.new(INPUT_PATH).call.each do |watchlist, lines|
  generate_csv(watchlist) do |csv|
    lines.each do |line|
      csv << Array.new(COLUMNS.size).tap do |result|
        result[COLUMNS.index('Symbol')] = line.symbol&.upcase if COLUMNS.index('Symbol')
        result[COLUMNS.index('UserNotes')] = line.user_notes if COLUMNS.index('UserNotes')
      end
    end
  end
end
