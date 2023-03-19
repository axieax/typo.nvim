test:
	nvim --headless --noplugin -u tests/init.vim -c "PlenaryBustedDirectory tests/typo {minimal_init = 'tests/init.vim'}"
