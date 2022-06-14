# ArgoCD

Get the initial password :

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

This was not working, so I just set it to "admin", and changed it once logged (see https://github.com/argoproj/argo-cd/blob/master/docs/faq.md#i-forgot-the-admin-password-how-do-i-reset-it) :

```
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$VnL1iI2bgUDJE1hmgBLLYeJWTalVjKLeOdTo9o8EIAtlkfkPNzhtO",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
```
