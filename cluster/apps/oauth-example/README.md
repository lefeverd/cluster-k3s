# Oauth example

Example application using :

- Traefik forwardAuth: https://doc.traefik.io/traefik/middlewares/http/forwardauth/  
This allows traefik to use an external service to forward authentication.
- Traefik-forward-auth : https://github.com/thomseddon/traefik-forward-auth  
This is the external service that we deploy, that will handle authentication.  
Traefik proxy doesn't natively support OpenID Connect, so we use this.
- Echoserver, this is the app that we protect.
- An OpenID connect provider, such as Okta, Auth0, ...

