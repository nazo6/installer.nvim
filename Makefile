.PHONY: test
test:
	nvim --headless -u ./tests/minimal.vim -c "PlenaryBustedDirectory tests\\spec\\"
