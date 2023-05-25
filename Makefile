.PHONY: all all-win sm sm-win

all: sm

all-win: sm-win

sm:
	chmod +x ./scripts/sm.sh
	./scripts/sm.sh

sm-win:
	./scripts/sm.sh win
