.PHONY: generate-registry-secret

all: generate-registry-secret

SECRET_DOMAIN = $(shell sops -d --extract '["stringData"]["SECRET_DOMAIN"]' ../../config/cluster-secrets.sops.yaml)
SECRET_DOCKER_USERNAME = $(shell sops -d --extract '["stringData"]["SECRET_SIMPLEBOOKMARKS_DOCKER_USERNAME"]' ../../config/cluster-secrets.sops.yaml)
SECRET_DOCKER_PASSWORD = $(shell sops -d --extract '["stringData"]["SECRET_SIMPLEBOOKMARKS_DOCKER_PASSWORD"]' ../../config/cluster-secrets.sops.yaml)
SECRET_DOCKER_EMAIL = $(shell sops -d --extract '["stringData"]["SECRET_SIMPLEBOOKMARKS_DOCKER_EMAIL"]' ../../config/cluster-secrets.sops.yaml)

generate-registry-secret:
	kubectl create secret docker-registry docker-registry-harbor --docker-server=harbor.$(SECRET_DOMAIN)/simplebookmarks --docker-username=$(SECRET_DOCKER_USERNAME) --docker-password=$(SECRET_DOCKER_PASSWORD) --docker-email=$(SECRET_DOCKER_EMAIL) --dry-run=client -o yaml > ./docker-secret.yaml
