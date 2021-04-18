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

## Dependencies

* Ruby 2.7.2

## Build

To replace the placeholders rename `.env.example` to `.env` and fill in with
your values. Then run

```bash
make
```
