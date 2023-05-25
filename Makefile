.PHONY: all all-win sm sm-win

all: sm instances

all-win: sm-win instances

sm:
	chmod +x ./scripts/sm.sh
	./scripts/sm.sh

sm-win:
	./scripts/sm.sh win

instances:
	py ./scripts/instance.py