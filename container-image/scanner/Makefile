SHELL=/bin/bash

.DEFAULT_GOAL := run

ARGS = $(filter-out $@,$(MAKECMDGOALS))

# don't run unknown targets, i.e. if they're given as arguments to `run`
%:
	@:

build:
	docker build -t ghcr.io/deps-fyi/gophercon-uk-2025 .

pull:
		docker pull ghcr.io/deps-fyi/gophercon-uk-2025

has_image:
	if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^ghcr.io/deps-fyi/gophercon-uk-2025'; then \
		docker pull ghcr.io/deps-fyi/gophercon-uk-2025; \
	fi

run: has_image
	docker run -e RENOVATE_TOKEN -e RENOVATE_PLATFORM -e EXTERNAL_PWD=$(PWD) -e RENOVATE_LOG_LEVEL -v $(PWD):/app -ti ghcr.io/deps-fyi/gophercon-uk-2025 $(ARGS)

run-debug: has_image
	# run with additional DEBUG_MODE env var
	$(MAKE) run RENOVATE_LOG_LEVEL=debug
