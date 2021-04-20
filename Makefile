test:
	vusted --shuffle -v
.PHONY: test

doc:
	rm -f ./doc/genvdoc.txt
	nvim --headless --clean -n +"lua dofile('./spec/lua/genvdoc/doc.lua')" +"quitall!"
	cat ./doc/genvdoc.txt
.PHONY: doc
