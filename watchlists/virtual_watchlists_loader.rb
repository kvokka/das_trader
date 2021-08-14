class VirtualWatchlistsLoader
  # here is the spot where desired watchlists should be defined
  WATCHLISTS = [
    OpenStruct.new(name: '52wHi', virtual_watchlist_number: 1, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,ta_averagetruerange_o0.5,ta_highlow52w_nh,ta_volatility_wo3&ft=4&o=ticker'),
    OpenStruct.new(name: 'TodayHi5', virtual_watchlist_number: 2, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_perf2_d5o&ft=4&o=ticker'),
    OpenStruct.new(name: '50dLow', virtual_watchlist_number: 11, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_averagetruerange_o0.5,ta_highlow50d_nl,ta_volatility_wo3&ft=4&o=ticker'),
    OpenStruct.new(name: 'TodayLo5', virtual_watchlist_number: 12, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_perf2_d5u&ft=4&o=ticker'),
  ]

  COLUMNS_SETTINGS = '1,14,4,8,32,26,0,10,0,10,0,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'
  COLUMNS_WIDTHS_SETTINGS = '0,67,0,51,70,0,0,0,101,52,68,55,100,91,61,0,0,0,0,0,0,0,0,0,0,0,640,0,60,0,0,0,57'

  class << self
    def load
      WATCHLISTS.each do |wl|
        Finviz.tickers(uri: wl.url).each do |symbol|
          ::Loader.loaded[wl] << Loader::Line.new(symbol: symbol, raw_user_notes: [wl.name.dup])
        end
      end
    end

    def update_config
      ::Loader.loaded.each do |wl, lines|
        next unless wl&.virtual_watchlist_number

        wl_number = wl.virtual_watchlist_number
        Das.instance.config.reject! do |l|
          l =~ %r{MKTUSERNOTES#{wl_number}:|
                  MKTMDSYM#{wl_number}:|
                  MKTVIEW:Title#{wl_number}:|
                  MKTVIEW#{wl_number}:COL:|
                  MKTVIEW#{wl_number}:COLWID:
                }x
        end
        Das.instance.config << "MKTVIEW:Title#{wl_number}:autocreated-#{wl.name}\r\n"
        Das.instance.config << "MKTVIEW#{wl_number}:COL:#{COLUMNS_SETTINGS}\r\n"
        Das.instance.config << "MKTVIEW#{wl_number}:COLWID:#{COLUMNS_WIDTHS_SETTINGS}\r\n"

        lines.each_with_index do |line, index|
          next unless line.symbol

          Das.instance.config << "MKTMDSYM#{wl_number}:#{'%03d' % index}:#{line.symbol.upcase}\r\n"
          Das.instance.config << "MKTUSERNOTES#{wl_number}:#{'%03d' % index}:#{line.user_notes}\r\n"
        end
      end
    end
  end
end