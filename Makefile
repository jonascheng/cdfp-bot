.DEFAULT_GOAL := help

APPLICATION?=cdfp-bot
COMMIT_SHA?=$(shell git rev-parse --short HEAD)
DOCKER?=docker
DOCKERHUB_OWNER?=jonascheng
DOCKER_IMG_NAME=${DOCKERHUB_OWNER}/${APPLICATION}
PWD?=$(shell pwd)

.PHONY: docker-build
docker-build: ## build docker image
        ${DOCKER} build -t ${DOCKER_IMG_NAME}:${COMMIT_SHA} .

.PHONY: docker-run
docker-run: docker-build ## run docker image
        ${DOCKER} run -d ${DOCKER_IMG_NAME}:${COMMIT_SHA}

.PHONY: help
help: ## prints this help message
        @echo "Usage: \n"
        @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
