.PHONY: install lint format test run

install:
	$(shell which python3) -m pip install -r requirements.txt
	$(shell which python3) -m pip install black mypy

lint:
	mypy . --ignore-missing-imports
	black --check .

format:
	black .

test:
	pytest

run:
	python main.py
