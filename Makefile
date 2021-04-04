build:
	@which envsubst > /dev/null
	@source .env && ACCOUNT_NUMBER=$$DEMO_ACCOUNT_NUMBER envsubst < hotkey-base.htk > hotkey.htk
	@source .env && ACCOUNT_NUMBER=$$LIVE_ACCOUNT_NUMBER envsubst < hotkey-base.htk > hotkey_live.htk
	@echo Done
