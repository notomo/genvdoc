test:
	vusted --shuffle -v
.PHONY: test

doc:
	nvim --headless --clean -n +"lua dofile('./spec/doc.lua')" +"quitall!"
	cat ./doc/genvdoc.txt
.PHONY: doc
