# Hetzner

This will create the k3s masters and workers nodes.

The Hetzner API token is encrypted in the secret.sops.yaml file, it can be modified with :

```
sops secret.sops.yaml
```

Sops needs to be installed and correctly configured, see main README (it uses `SOPS_AGE_KEY_FILE` env var).
