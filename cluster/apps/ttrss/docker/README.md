# TTRSS

## PostgreSQL

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install postgres-ttrss --namespace ttrss -f ./charts-values/postgres-ttrss.yaml bitnami/postgresql
```

## Mercury

Mercury is a service that gets fulltext from articles.  
The plugin needs a running mercury service to work.

## Docker registry secret

To generate the secret yaml :

```
make generate-registry-secret
```

It will use the secrets defined in the base/cluster-secrets.sops.yaml and create a
docker-secret.yaml along the other resources.

## TTRSS

We build our own image :

```
make
make push
```

### Plugins

- Mercury, uses the Mercury instance we deploy, to be able to extract full text from articles
- We added Fever API plugin to be able to use the Reeder app on iPad : https://github.com/DigitalDJ/tinytinyrss-fever-plugin  
Enable it in the plugins, then a new section in the configuration appears to configure it.  
The URL is then https://rss.horsducommun.be/plugins.local/fever/
