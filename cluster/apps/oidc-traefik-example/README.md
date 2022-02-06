# OIDC Traefik example

Example application using :

- Traefik forwardAuth: https://doc.traefik.io/traefik/middlewares/http/forwardauth/  
This allows traefik to use an external service to forward authentication.
- Traefik-forward-auth : https://github.com/thomseddon/traefik-forward-auth  
This is the external service that we deploy, that will handle authentication.  
Traefik proxy doesn't natively support OpenID Connect, so we use this.
- Echoserver, this is the app that we protect.
- An OpenID connect provider, such as Okta, Auth0, ...

## Downsides

For now, OIDC ID Token is not forwarded, see https://github.com/thomseddon/traefik-forward-auth/pull/100

This means the upstream will not get the user info, just the e-mail.  
This is why we decided to use oauth2-proxy for now.
