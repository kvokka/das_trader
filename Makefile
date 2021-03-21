build:
	@source .env && eval "echo \"$$(cat hotkey-base.htk)\"" > hotkey.htk
	@echo Done
