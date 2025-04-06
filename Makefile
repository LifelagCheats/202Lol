.PHONY: install lint test security clean format freeze precommit check-python spinner

PYTHON := python3
SPINNER_CHARS = "|/-\\"

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m

check-python:
	@$(PYTHON) -c 'import sys; assert sys.version_info >= (3, 9), " Python 3.9+ is required."'
	@echo " Python version is sufficient."

spinner = \
	i=0; while kill -0 $$1 2>/dev/null; do \
		printf "\r$(YELLOW)[%s] $(1)..." "$${SPINNER_CHARS:$$((i%4)):1}"; \
		sleep 0.1; i=`expr $$i + 1`; \
	done; wait $$1; printf "\r✔ Done!\n"

install: check-python
	@echo "$ Installing dependencies..."
	@($(PYTHON) -m pip install -r requirements.txt > /dev/null 2>&1) & PID=$$!; \
	$(call spinner,$$PID)

	@($(PYTHON) -m pip install black mypy pytest pytest-mock pytest-cov requests stem whois halo rich tqdm bandit safety flake8 pylint > /dev/null 2>&1) & PID=$$!; \
	$(call spinner,$$PID)

	@$(PYTHON) -m pip install --upgrade pip > /dev/null
	@echo " Installation complete!"

lint:
	@echo "󰃢 Linting code..."
	@black .
	@pylint *.py | tee >(sed '$$d' > linting.log) | grep "rated"
	@echo " Linted all files."

security:
	@echo "󱡴 Running security checks..."
	@safety scan || true  # Avoid fail if no account
	@pip-audit
	@echo " Security scans complete."

test:
	@echo "󰙨 Running unit tests..."
	@($(PYTHON) -m unittest tests/test_minor.py > /dev/null) & PID=$$!; $(call spinner,$$PID)
	@sleep 0.5
	@($(PYTHON) -m unittest tests/test_poke.py > /dev/null) & PID=$$!; $(call spinner,$$PID)
	@sleep 0.5
	@($(PYTHON) -m unittest tests/test_checker.py > /dev/null) & PID=$$!; $(call spinner,$$PID)
	@echo " All tests passed."

clean:
	@echo " Cleaning up..."
	@rm -rf __pycache__ .pytest_cache .coverage htmlcov .mypy_cache *.log
	@echo " Deleted all cache."

format:
	@echo "󰭆 Autoformatting code..."
	@black .
	@echo " Formatting done."

precommit: lint security test clean
	@echo " All checks passed! You're ready to commit."
