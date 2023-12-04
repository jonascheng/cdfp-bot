.DEFAULT_GOAL := help

APPLICATION?=cdfp-bot
COMMIT_SHA?=$(shell git rev-parse --short HEAD)
DOCKER?=docker
DOCKERHUB_OWNER?=jonascheng
DOCKER_IMG_NAME=${DOCKERHUB_OWNER}/${APPLICATION}
PWD?=$(shell pwd)

.PHONY: cleanup
cleanup: ## cleanup
	${DOCKER} stop ${APPLICATION} || true

.PHONY: docker-build
docker-build: ## build docker image
	${DOCKER} build -t ${DOCKER_IMG_NAME}:${COMMIT_SHA} .

.PHONY: docker-run
docker-run: cleanup docker-build ## run docker image
	${DOCKER} run --rm -v /tmp/${APPLICATION}/screenshot:/screenshot -v /tmp/${APPLICATION}/source:/source --privileged --name ${APPLICATION} -d ${DOCKER_IMG_NAME}:${COMMIT_SHA}

.PHONY: docker-debug
docker-debug: cleanup docker-build ## debug docker image
	${DOCKER} run --rm -v ${PWD}:/app -v /tmp/${APPLICATION}/screenshot:/screenshot -v /tmp/${APPLICATION}/source:/source --name ${APPLICATION} -it ${DOCKER_IMG_NAME}:${COMMIT_SHA} bash

.PHONY: docker-push
docker-push: docker-build ## push docker image
	${DOCKER} push ${DOCKER_IMG_NAME}:${COMMIT_SHA}

.PHONY: help
help: ## prints this help message
	@echo "Usage: \n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
