build:
	@source .env && eval "echo \"$$(cat hotkeys-base.htk)\"" > hotkeys.htk
	@echo Done
