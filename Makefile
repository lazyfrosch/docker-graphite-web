DOCKER_REPO := ${DOCKER_REPO}
ifeq ($(DOCKER_REPO),)
DOCKER_REPO := lazyfrosch/graphite-web
endif

DOCKER_REGISTRY := ${DOCKER_REGISTRY}
ifneq ($(DOCKER_REGISTRY),)
DOCKER_REPO := $(DOCKER_REGISTRY)/$(DOCKER_REPO)
endif

ifeq ($(DOCKER_TAG),)
DOCKER_TAG := latest
endif

FROM := $(shell grep FROM Dockerfile | cut -d" " -f2)
IMAGE := $(DOCKER_REPO):$(DOCKER_TAG)

all: pull build

pull:
	docker pull "$(IMAGE)" || true
	docker pull "$(FROM)"

build:
	docker build --tag "$(IMAGE)" .

push:
	docker push "$(IMAGE)"

clean:
	if (docker inspect --type image "$(IMAGE)" >/dev/null 2>&1); then docker rmi "$(IMAGE)"; fi
