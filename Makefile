SHELL := /bin/bash
TRAVIS_PYTHON_VERSION ?= $(shell python3 --version | cut -d ' ' -f 2)
PREFIX ?= /usr/local

all:
	./any-module/updateBootstraper.py
	./bilingual-module/updateBootstraper.py
	./hfst-language-module/updateBootstraper.py
	./lttoolbox-language-module/updateBootstraper.py

apertium_init.py: apertium-init.py
	cp $< $@

dist: all apertium_init.py
	python3 setup.py sdist

release: all apertium_init.py
	python3 setup.py sdist bdist_wheel upload --sign

test-release: all apertium_init.py
	python3 setup.py sdist bdist_wheel upload --repository https://test.pypi.org/legacy/ --sign

test:
	flake8 *.py **/*.py
	mypy --strict apertium-init.py
	coverage run -m unittest --verbose --buffer
	coverage report --show-missing --fail-under 70
	if [[ "$(TRAVIS_PYTHON_VERSION)" != '3.4'* && $(TRAVIS_PYTHON_VERSION) != '3.5'*  ]]; then \
		git diff --exit-code apertium-init.py; \
	fi

install:
	@install -d $(DESTDIR)$(PREFIX)/bin
	install -m755 apertium-init.py $(DESTDIR)$(PREFIX)/bin/apertium-init

clean:
	rm -rf dist/ build/ *.egg-info/ .mypy_cache/ apertium_init.py
