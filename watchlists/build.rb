#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'ostruct'
require 'pathname'

require_relative 'loader'
require_relative 'das_config'
require_relative 'alerts_creator'

# Empty watchlist creation is a little fuck in DAS
# So let's create a template for it

# idk why, but DAS watchlists have to end with empty column
COLUMNS = ['Symbol', 'Tick', '% Change', 'Change', 'Last', 'Volume', 'RVOL', 'Exchange', 'UserNotes', nil].freeze

FileUtils.mkdir_p(INPUT_PATH = Pathname.new(ENV.fetch('INPUT_PATH', 'input')))
FileUtils.mkdir_p(OUTPUT_PATH = Pathname.new(ENV.fetch('OUTPUT_PATH', 'output')))

def generate_csv(watchlist)
  csv_filename = "#{watchlist}.csv"
  CSV.open(OUTPUT_PATH.join(csv_filename), 'wb') do |csv|
    csv << COLUMNS
    yield csv
  end
end

def all_watchlists
  @all_watchlists ||= CsvLoader.new(INPUT_PATH).call
end

generate_csv('empty') { |csv| 100.times { csv << Array.new(COLUMNS.size) } }

all_watchlists.each do |file_desc, lines|
  generate_csv(file_desc.name) do |csv|
    lines.each do |line|
      csv << Array.new(COLUMNS.size).tap do |result|
        result[COLUMNS.index('Symbol')] = line.symbol&.upcase if COLUMNS.index('Symbol')
        result[COLUMNS.index('UserNotes')] = line.user_notes if COLUMNS.index('UserNotes')
      end
    end
  end
end

AlertsCreator.new(all_watchlists).call
Das.instance.update!
