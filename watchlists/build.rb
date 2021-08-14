#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'ostruct'
require 'pathname'

require_relative 'csv_loader'
require_relative 'das_config'
require_relative 'alerts_creator'
require_relative 'csv_generator'

FileUtils.mkdir_p(INPUT_PATH = Pathname.new(ENV.fetch('INPUT_PATH', 'input')))
FileUtils.mkdir_p(OUTPUT_PATH = Pathname.new(ENV.fetch('OUTPUT_PATH', 'output')))

CsvGenerator.generate_empty

all_watchlists = CsvLoader.new(INPUT_PATH).call

all_watchlists.each { |file_desc, lines| CsvGenerator.generate_from_file_desc file_desc, lines }

AlertsCreator.new(all_watchlists).call
Das.instance.update!
