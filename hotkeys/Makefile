include .env.example .env
export

build:
	@which envsubst > /dev/null
	@VERSION=$$(cat VERSION) ACCOUNT_NUMBER=$$DEMO_ACCOUNT_NUMBER envsubst < hotkey-base.htk > $$OUTPUT_PATH/hotkey.htk
	@VERSION=$$(cat VERSION) ACCOUNT_NUMBER=$$LIVE_ACCOUNT_NUMBER envsubst < hotkey-base.htk > $$OUTPUT_PATH/hotkey_live.htk
	@echo Hotkey files created at $$OUTPUT_PATH
