class VirtualWatchlistsLoader
  # here is the spot where desired watchlists should be defined
  WATCHLISTS = [
    OpenStruct.new(name: '50dHi_rvol2', virtual_watchlist_number: 1, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,sh_relvol_o2,ta_averagetruerange_o0.5,ta_highlow50d_nl&ft=4&o=ticker'),
    OpenStruct.new(name: '50dHi', virtual_watchlist_number: 1, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_averagetruerange_o0.5,ta_highlow50d_nh&ft=4&o=ticker'),
    OpenStruct.new(name: '50dHi_0-3%', virtual_watchlist_number: 1, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_averagetruerange_o0.5,ta_highlow50d_b0to3h&ft=4&o=ticker'),
    OpenStruct.new(name: 'MarubozuWhiteDay', virtual_watchlist_number: 2, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_averagetruerange_o0.5,ta_candlestick_mw&ft=4&o=ticker'),
    OpenStruct.new(name: 'TodayHi5', virtual_watchlist_number: 2, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_perf2_d5o&ft=4&o=ticker'),
    OpenStruct.new(name: '50dLow_rvol2', virtual_watchlist_number: 11, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,sh_relvol_o2,ta_averagetruerange_o0.5,ta_highlow50d_nl,ta_volatility_wo3&ft=4&o=ticker'),
    OpenStruct.new(name: '50dLow', virtual_watchlist_number: 11, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_averagetruerange_o0.5,ta_highlow50d_nl,ta_volatility_wo3&ft=4&o=ticker'),
    OpenStruct.new(name: '50dLow_0-3%', virtual_watchlist_number: 11, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_averagetruerange_o0.5,ta_highlow50d_a0to3h&ft=4&o=ticker'),
    OpenStruct.new(name: 'TodayLo5', virtual_watchlist_number: 12, url: 'https://finviz.com/screener.ashx?v=351&f=cap_midover,ind_stocksonly,sh_curvol_o2000,sh_price_o5,ta_perf2_d5u&ft=4&o=ticker'),
  ]

  # filtering in finviz sucks, so for now kick some noise manually
  BLACKLISTED_SYMBOLS = %w[
    acgl
    aph
    bbwi
    crm
    hta
    jef
    mdt
    mrvl
  ]

  COLUMNS_SETTINGS = '1,14,4,8,32,26,0,10,0,10,0,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'
  COLUMNS_WIDTHS_SETTINGS = '0,67,0,51,70,0,0,0,101,52,68,55,100,91,61,0,0,0,0,0,0,0,0,0,0,0,640,0,60,0,0,0,57'

  class << self
    def load
      WATCHLISTS.each do |wl|
        Finviz.tickers(uri: wl.url).each do |symbol|
          next if BLACKLISTED_SYMBOLS.include?(symbol)

          l = Loader::Line.new(symbol: symbol, raw_user_notes: [wl.name.dup])
          ::Loader.loaded[wl].include?(l) || (::Loader.loaded[wl] << l)
        end
        ::Loader.loaded[wl] << Loader::Line.new
      end
    end

    def update_config
        merged_watchlists.each do |wl_number, lines|
        Das.instance.config.reject! do |l|
          l =~ %r{MKTUSERNOTES#{wl_number}:|
                  MKTMDSYM#{wl_number}:|
                  MKTVIEW:Title#{wl_number}:|
                  MKTVIEW#{wl_number}:COL:|
                  MKTVIEW#{wl_number}:COLWID:
                }x
        end
        wl_name = WATCHLISTS.select{ |wl| wl.virtual_watchlist_number == wl_number }.map(&:name).join('+')
        Das.instance.config << "MKTVIEW:Title#{wl_number}:autocreated-#{wl_name}\r\n"
        Das.instance.config << "MKTVIEW#{wl_number}:COL:#{COLUMNS_SETTINGS}\r\n"
        Das.instance.config << "MKTVIEW#{wl_number}:COLWID:#{COLUMNS_WIDTHS_SETTINGS}\r\n"

        lines.each_with_index do |line, index|
          Das.instance.config << "MKTMDSYM#{wl_number}:#{'%03d' % index}:#{line.symbol.to_s.upcase}\r\n"
          Das.instance.config << "MKTUSERNOTES#{wl_number}:#{'%03d' % index}:#{line.user_notes || 0}\r\n"
        end
      end
    end

    private

    def merged_watchlists
      @merged_watchlists ||= ::Loader.loaded.each_with_object({}) do |(wl,lines), acc|
        next unless wl&.virtual_watchlist_number

        acc[wl.virtual_watchlist_number] ||= []
        acc[wl.virtual_watchlist_number] +=lines
      end
    end
  end
end