.PHONY: build

all: build

SECRET_DOMAIN = $(shell sops -d --extract '["stringData"]["SECRET_DOMAIN"]' ../../../config/cluster-secrets.sops.yaml)
SECRET_DOCKER_USERNAME = $(shell sops -d --extract '["stringData"]["SECRET_DOCKER_USERNAME"]' ../../../config/cluster-secrets.sops.yaml)
SECRET_DOCKER_PASSWORD = $(shell sops -d --extract '["stringData"]["SECRET_DOCKER_PASSWORD"]' ../../../config/cluster-secrets.sops.yaml)
SECRET_DOCKER_EMAIL = $(shell sops -d --extract '["stringData"]["SECRET_DOCKER_EMAIL"]' ../../../config/cluster-secrets.sops.yaml)

build:
	ttrss_rev=ceb8179ccc692430d52deb8e154e07a78569b412 docker build -t harbor.$(SECRET_DOMAIN)/horsducommun/ttrss .

push:
	docker push harbor.$(SECRET_DOMAIN)/horsducommun/ttrss

generate-registry-secret:
	kubectl create secret docker-registry docker-registry-ttrss --docker-server=harbor.$(SECRET_DOMAIN)/horsducommun --docker-username=$(SECRET_DOCKER_USERNAME) --docker-password=$(SECRET_DOCKER_PASSWORD) --docker-email=$(SECRET_DOCKER_EMAIL) --dry-run=client -o yaml > ../docker-secret.yaml
