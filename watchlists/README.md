## Watch lists

Simplification of watchlists creation
Transform all *.txt files from `input` folder to `.csv` format with pre-defined columns

## File format description

Each line of the file will be the row in the watchlist (including empty lines)
File should follow the format `[ticker] [das user comments]`. Examples:

```
AAPL
TSLA when the moon is in 3rd phase you should dump it, otherwise avoid buying
```

## Alerts

For user comments in the last updated watchlists file, which match Regex
alerts will be added for supported actions:

* `A` L1 Ask price
* `B` L1 Bid price
* `L` Last trade price
* `V` Volume traded

Examples:

* `MyComment A > 42.15, V>= 1000000`
* `L <= 10 Dump it!`
* `Sell L<  30 Buy A > 40`

## Dependencies

* Ruby 2.7.2

## Build

To replace the placeholders rename `.env.example` to `.env` and fill in with
your values. Then run

```bash
make
```
