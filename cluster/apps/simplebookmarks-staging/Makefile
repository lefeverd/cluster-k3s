.PHONY: generate-registry-secret

all: generate-registry-secret

SECRET_DOMAIN = $(shell sops -d --extract '["stringData"]["SECRET_DOMAIN"]' ../../base/cluster-secrets.sops.yaml)
SECRET_DOCKER_USERNAME = $(shell sops -d --extract '["stringData"]["SECRET_SIMPLEBOOKMARKS_DOCKER_USERNAME"]' ../../base/cluster-secrets.sops.yaml)
SECRET_DOCKER_PASSWORD = $(shell sops -d --extract '["stringData"]["SECRET_SIMPLEBOOKMARKS_DOCKER_PASSWORD"]' ../../base/cluster-secrets.sops.yaml)
SECRET_DOCKER_EMAIL = $(shell sops -d --extract '["stringData"]["SECRET_SIMPLEBOOKMARKS_DOCKER_EMAIL"]' ../../base/cluster-secrets.sops.yaml)

generate-registry-secret:
	kubectl create secret docker-registry docker-registry-harbor --docker-server=harbor.$(SECRET_DOMAIN)/horsducommun --docker-username=$(SECRET_DOCKER_USERNAME) --docker-password=$(SECRET_DOCKER_PASSWORD) --docker-email=$(SECRET_DOCKER_EMAIL) --dry-run=client -o yaml > ./docker-secret.yaml
