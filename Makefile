IMAGE_NAME	?= semvergen
VERSION	?= $(shell pipenv run python semvergen/generate.py)

.PHONY: build-docker
build-docker: clean set-version gen-requirements
	docker build -t ${IMAGE_NAME} .
	docker tag ${IMAGE_NAME} ${IMAGE_NAME}:${VERSION}

.PHONY: build-pypi
build-pypi: clean set-version gen-requirements
	python setup.py sdist bdist_wheel

.PHONY: publish-pypi
publish-pypi: build-pypi
	twine upload dist/* --repository-url '$(TWINE_REPOSITORY_URL)' --username '$(TWINE_USERNAME)' --password '$(TWINE_PASSWORD)'

.PHONY: test
test: clean
	pipenv run python semvergen/tests/run.py

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
