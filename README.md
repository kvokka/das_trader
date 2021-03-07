# Das Trader Pro config

Das Version 5.6.4.2

## Hotkeys

### Precautions

This config is here to organise my hotkeys and get better manage of them. I have
zero responsibility for your using of any part of this script. This is for
educational/entreatment purpose only.

**Always test all your hotkeys before usage**

### General notes

The main idea is to group all the keys and config it from here, cos
copy/paste in DAS in very inconvenient, pls it should help to keep config clear
and notes separate. I'm still not sure about some hotkeys scripts, but want to
have them around.

`Ctrl` key is used for the most combinations. This helps to avoid any accidental
key press
`Shift` key separately or with `Ctrl` combination means `NOW!`

Some hotkeys are using `TRP225324` account as a placeholder, replace it with your
account before usage.

Almost all hotkeys does not change the route, so I prefer not select it in the
hotkeys and define it in the trading session process. Keep in mind that, and
move the routes back after using market orders.

The keys organisation is in the way, that on the left we have the keys for Buy
and on the right for Sell orders. The keys which are for opposite purpose are
intentionally on the different sides of the keyboard (instead of using the
concept of combinations like Ctrl for sale and Shift for Buy) cos for me
personally it helps to avoid the errors. If you do not like this concept, then
feel free to fork and make your own config.

I do not want to have hotkeys for faster price/shares changes than this, cos it
may produce expensive avoidable errors. In case of the fast price moving I
prefer to type price manually, or use chart trader, or use bid-ask prices (all
this techniques give way less room for human error).

Since my style assume very active trading, instead of creating 1 STOP order for
each trade i prefer to exit manually and update 1 STOP for all my entries. For
less active traders this might be not convenient.

### Key groups

Just to keep the things grouped, I added a prefix to each button name. This
convention allows to get simpler sorting in DAS Trader.

Atm there are a few key groups:

* `F1`-`F3` Buy orders for instant or almost instant execution

* `F5`-`F8` Chart Trader
* ` Chart trader stop loss for entire position (old stops should be removed manually)

* `F9`-`F12` Sell orders for instant or almost instant execution

* `Ctrl+1` - `Ctrl+5` switch chart time frame

* Arrow keys are for changing price and order size

* `ESC` related combination are for all orders cancel or quick exit purposes

* `Home`-`End`-`PageUp`-`PageDown` group is for charts control

* `Ctrl-Z` - `Ctrl-C` with possible shift combination is for closing part or all
the position (with `Shift` key it'll be exit by market, otherwise by current mid
price). note that by DAS Trader design this have to cancel all the orders before
running this script.

### Unused combinations

Atm I found for myself, that it is easier to manually create STOP and TP orders
instead of using OCO orders. May be it'll be subject to change, so for now I'll
leave below a few examples of how it may work.

notes:

* market orders does not work on both demo and live account outside RTH
* `LowPrice` if always less than `AvgCost2` and `HighPrice` is always greater
than `AvgCost2`
* Position size can be equal current entered shares with `QTY:Share` or entire
position with `QTY:Pos`

```
:Buy ASK+.10 and Add TakeProfit order 20 cents above:ROUTE=SMRTL;Price=Ask+0.10; TIF=DAY+; BUY=Send;TriggerOrder=RT:LIMIT PX:AvgCost2+0.20 ACT:SELL QTY:Share TIF:GTC

:Sell Ask and Add TakeProfit 1 and StopLoss 2:ROUTE=SMRTL;Price=Ask;TIF=DAY+;SELL=Send;TriggerOrder=RT:STOP STOPTYPE:RANGE LowPrice:AvgCost2-.1 HighPrice:AvgCost2+2 ACT:BUY QTY:Share TIF:DAY+

:This is a hotkey to send an automatic range order at 2to1 all or nothing(Short position):~ 161:ROUTE=LIMIT;Price=Ask+0.10;Share=100;TIF=DAY+;BUY=Send;TriggerOrder=RT:STOP STOPTYPE:RANGE LowPrice:AvgCost2-.40 HighPrice:AvgCost2+.20 ACT:SELL QTY:POS TIF:DAY+
```
