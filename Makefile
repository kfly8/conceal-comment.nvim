.PHONY: test lint fmt fmt-check

PLENARY_DIR ?= $(HOME)/.local/share/nvim/site/pack/deps/start/plenary.nvim

test:
	nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

lint:
	luacheck lua ftplugin tests

fmt:
	stylua lua ftplugin tests

fmt-check:
	stylua --check lua ftplugin tests
