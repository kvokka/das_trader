class CsvGenerator
  # Empty watchlist creation is a little fuck in DAS
  # So let's create a template for it

  # idk why, but DAS watchlists have to end with empty column
  COLUMNS = ['Symbol', 'Tick', '% Change', 'Change', 'Last', 'Volume', 'RVOL', 'Exchange', 'UserNotes', nil].freeze

  class << self
    def generate_from_file_desc(file_desc, lines)
      return if file_desc.virtual

      generate(file_desc.name) do |csv|
        lines.each do |line|
          csv << Array.new(COLUMNS.size).tap do |result|
            result[COLUMNS.index('Symbol')] = line.symbol&.upcase if COLUMNS.index('Symbol')
            result[COLUMNS.index('UserNotes')] = line.user_notes if COLUMNS.index('UserNotes')
          end
        end
      end
    end

    def generate_empty
      generate('empty') { |csv| 100.times { csv << Array.new(COLUMNS.size) } }
    end

    private

    def generate(watchlist)
      csv_filename = "#{watchlist}.csv"
      CSV.open(OUTPUT_PATH.join(csv_filename), 'wb') do |csv|
        csv << COLUMNS
        yield csv
      end
    end
  end
end