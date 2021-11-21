test: ./script/nvim-treesitter/parser/lua.so
	vusted --shuffle -v
.PHONY: test

doc: ./script/nvim-treesitter/parser/lua.so
	rm -f ./doc/genvdoc.txt
	nvim --headless --clean -n +"lua dofile('./spec/lua/genvdoc/doc.lua')" +"quitall!"
	cat ./doc/genvdoc.txt
.PHONY: doc

./script/nvim-treesitter:
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git $@
./script/nvim-treesitter/parser/lua.so: ./script/nvim-treesitter
	nvim -u ./script/install.vim -c "TSInstallSync lua" -c quit
