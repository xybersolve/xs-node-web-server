#
# xs-node-web-server
#
# Build & push xs-node-web-server to docker.io/$(ORG)"
# $ make build
# $ make tag
# $ make login
# $ make push
#
# Start server using newest image
# $ make up
#
# TODO: ECR push
# TODO: Version bump & tagging
#
.PHONY: build tag push test deploy archive ssh help tag login push \
				tag-ecr login-ecr push-ecr

# Project Configuration
ORG := xybersolve
PROJECT := xs-node-web-server
VERSION := 1.0.4
IMAGE := xs-node-web-server
CONTAINER := xs-node-web-server
BACKUP_DIR := ./archives
PORT_EXT := 8282
PORT_INT := 3000

# Versioning Variables
#VERSION=$(shell node -pe "require('./package.json').version")
HASH_LONG := $(shell git log -1 --pretty=%H)
HASH_SHORT := $(shell git log -1 --pretty=%h)
TAG_GIT := $(IMAGE):$(HASH_SHORT)
TAG_VER := $(IMAGE):$(VERSION)
TAG_LATEST := "$(IMAGE):latest"
# REPO_GIT := $(ORG)/$(TAG_GIT)
# REPO_VER := $(ORG)/$(TAG_VER)
# REPO_LATEST := $(ORG)/$(TAG_LATEST)

# Archive Variables
DATE_TIME := $(shell date +"%Y%m%d" )
BACKUP_FILE := $(IMAGE)-$(DATE_TIME)-$(HASH_SHORT).tgz
BACKUP_PATH := "$(BACKUP_DIR)/$(BACKUP_FILE)"

build: ## Build docker image
	@echo 'build'
	@docker build -t "${IMAGE}" .

tag: ## Tag for DockerHub Registry
	@echo 'Tag image as follows:'
	#@echo "REPO_VER: $(REPO_VER)"
	@echo "GIT: $(IMAGE) $(ORG)/$(IMAGE):$(HASH_SHORT)"
	@echo "LATEST: $(IMAGE) $(ORG)/$(IMAGE):latest"

	@docker tag $(IMAGE) $(ORG)/$(IMAGE):$(HASH_SHORT)
	@docker tag $(IMAGE) $(ORG)/$(IMAGE):latest

test: ## Test whatever needs testing
	@echo 'Test what needs testing'

login: ## Login to DockerHub, expect user=<username>, pass=<password>
	# from terminal
	@docker login -u ${DOCKER_USER} -p ${DOCKER_PASS} #${DOCKER_HOST}
	# from jenkins
	# @docker login -u $(user) -p $(pass)

push: login ## Push to DockerHub registry
	@echo 'Pushing to registry, as:'
	@docker push $(ORG)/$(IMAGE):$(HASH_SHORT)
	@docker push $(ORG)/$(IMAGE):latest

deploy: ## Deploy into field
	@echo 'empty deploy'

up: ## Run the newest created image
	docker run -e NODE_ENV=local \
		--name $(IMAGE) -d \
		-p $(PORT_EXT):$(PORT_INT) \
		$(ORG)/$(IMAGE):$(HASH_SHORT)

down: ## Bring down the running container
	docker container kill $(CONTAINER) | true
	docker container rm $(CONTAINER)

clean: ## Delete the image
	@docker image rmi $(IMAGE)
	@docker image rmi $(REPO_LATEST)

archive: ## Archive image locally (compressed tar file)
	$(test -d $(OBJDIR) || shell mkdir -p $(BACKUP_DIR))
	@docker save -o $(BACKUP_PATH) $(IMAGE)

ssh: ## SSH into image
	@docker run -it --rm $(IMAGE):latest /bin/bash

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

# duluca
# "start": "node index",
# "test": "jasmine",
# "predocker:build": "npm test",
# "docker:build": "cross-conf-env docker image build . -t $npm_package_config_imageRepo:$npm_package_version",
# "postdocker:build": "npm run docker:tag",
# "prepush-tag": "git push origin :refs/tags/$npm_package_version",
# "push-tag": "git tag -fa $npm_package_version",
# "postpush-tag": "git push origin master --tags",
# "docker:tag": " cross-conf-env docker image tag $npm_package_config_imageRepo:$npm_package_version $npm_package_config_imageRepo:latest",
# "docker:run": "run-s -c docker:clean docker:runHelper",
# "docker:runHelper": "cross-conf-env docker run -e NODE_ENV=local --name $npm_package_config_imageName -d -p $npm_package_config_imagePort:3000 $npm_package_config_imageRepo",
# "predocker:publish": "echo Attention! Ensure `docker login` is correct.",
# "docker:publish": "cross-conf-env docker image push $npm_package_config_imageRepo:$npm_package_version",
# "postdocker:publish": "cross-conf-env docker image push $npm_package_config_imageRepo:latest",
# "docker:clean": "cross-conf-env docker rm -f $npm_package_config_imageName",
# "predocker:taillogs": "echo Web Server Logs:",
# "docker:taillogs": "cross-conf-env docker logs -f $npm_package_config_imageName",
# "docker:open:win": "echo Trying to launch on Windows && timeout 2 && start http://localhost:%npm_package_config_imagePort%",
# "docker:open:mac": "echo Trying to launch on MacOS && sleep 2 && URL=http://localhost:$npm_package_config_imagePort && open $URL",
# "docker:debugmessage": "echo Docker Debug Completed Successfully! Hit Ctrl+C to terminate log tailing.",
# "predocker:debug": "run-s docker:build docker:run",
# "docker:debug": "run-s -cs docker:open:win docker:open:mac docker:debugmessage docker:taillogs"
