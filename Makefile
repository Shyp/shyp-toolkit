.PHONY: patch minor deploy

patch:
	./bin/patch-library

minor:
	./bin/minor-library

major:
	./bin/major-library
