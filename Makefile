.PHONY: all all-win sm sm-win instances instances-win

all: sm instances

all-win: sm-win instances-win

sm:
	chmod +x ./scripts/sm.sh
	./scripts/sm.sh

sm-win:
	./scripts/sm.sh win

instances:
	python3 ./scripts/instance.py

instances-win:
	py ./scripts/instance.py