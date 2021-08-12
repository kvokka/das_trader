include .env.example .env
export

build:
	@which envsubst > /dev/null
	@mkdir -p $$OUTPUT_PATH
	@VERSION=$$(cat VERSION) ACCOUNT_NUMBER=$$DEMO_ACCOUNT_NUMBER envsubst < input/hotkey-base.htk > $$OUTPUT_PATH/hotkey.htk
	@VERSION=$$(cat VERSION) ACCOUNT_NUMBER=$$DEMO_ACCOUNT_NUMBER TRADE_ROUTE=LIMIT CHART_TRADE_ROUTE=LIMIT TRIGGER_ORDER_TRADE_ROUTE=LIMIT envsubst < input/hotkey-base.htk | sed s'/L2Bid/Bid/' | sed s'/L2Ask/Ask/' > $$OUTPUT_PATH/hotkey_replay.htk
	@VERSION=$$(cat VERSION) ACCOUNT_NUMBER=$$LIVE_ACCOUNT_NUMBER envsubst < input/hotkey-base.htk > $$OUTPUT_PATH/hotkey_live.htk
	@echo Hotkey files created at $$OUTPUT_PATH
