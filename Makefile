IMAGE_NAME	?= semvergen
VERSION	?= $(shell python semvergen/generate.py)

.PHONY: build-docker
build-docker: clean set-version gen-requirements
	docker build -t ${IMAGE_NAME} .
	docker tag ${IMAGE_NAME} ${IMAGE_NAME}:${VERSION}

.PHONY: build-pypi
build-pypi: set-version
	python setup.py sdist bdist_wheel

.PHONY: publish-pypi
publish-pypi: build-pypi
	pipenv run twine upload dist/* --username '$(TWINE_USERNAME)' --password '$(TWINE_PASSWORD)'

.PHONY: test-publish-pypi
test-publish-pypi: build-pypi
	pipenv run twine upload dist/* -r testpypi

.PHONY: test
test: clean
	pipenv run pytest

.PHONY: test-ci
test-ci: setup test

.PHONY: setup
setup: gen-requirements
	pipenv install; pipenv run python setup.py develop;

.PHONY: set-version
set-version: get-version
	echo '__version__ = "${VERSION}"' > semvergen/_version.py

.PHONY: get-version
get-version:
	echo ${VERSION}

.PHONY: gen-requirements
gen-requirements:
	pipenv lock -r | tail -n +2 > requirements.txt

.PHONY: clean
clean:
	rm -Rf .coverage build dist requirements.txt
	rm -Rf .cache
	rm -Rf semvergen_cli.egg-info

.SILENT:
