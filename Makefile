.PHONY: all all-win build build-win

all: build

all-win: build-win

build:
	chmod +x ./scripts/build.sh
	./scripts/build.sh

build-win:
	./scripts/build.sh win
