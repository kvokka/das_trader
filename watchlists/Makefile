include .env.example .env
export

build:
	@which envsubst > /dev/null
	@mkdir -p $$OUTPUT_PATH
	@./build.rb
	@echo Watchlists files created at $$OUTPUT_PATH
