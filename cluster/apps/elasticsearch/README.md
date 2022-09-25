# ELK

## Certificates creation

See [s/blob/7.17/elasticsearch/examples/security/Makefile](https://github.com/elastic/helm-charts/blob/v7.17.3/elasticsearch/examples/security/Makefile)

CA and client certs were generated using es docker image, with :

```
docker run -ti --rm --name es -u $(id -u) -v $(pwd):/app docker.elastic.co/elasticsearch/elasticsearch:8.4.1 bash

/usr/share/elasticsearch/bin/elasticsearch-certutil ca
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /app/elastic-stack-ca.p12 --dns logstash -pass '' --ca-pass '' --out /app/logstash.p12
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /app/elastic-stack-ca.p12 --dns elastic -pass '' --ca-pass '' --out /app/elastic.p12
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /app/elastic-stack-ca.p12 --dns kibana -pass '' --ca-pass '' --out /app/kibana.p12
```

We can then create the crt, pem and key files out of the p12 :

```
openssl pkcs12 -nodes -passin pass:'' -in elastic-stack-ca.p12 -out elastic-stack-ca.pem
openssl pkcs12 -nodes -passin pass:'' -in elastic.p12 -out elastic.pem
openssl pkcs12 -nodes -passin pass:'' -in kibana.p12 -out kibana.pem
openssl pkcs12 -nodes -passin pass:'' -in logstash.p12 -out logstash.pem

openssl pkcs12 -in elastic-stack-ca.p12 -out elastic-stack-ca.crt -nodes
openssl pkcs12 -in elastic.p12 -out elastic.crt -nodes
openssl pkcs12 -in elastic.p12 -out elastic.key -nodes -nocerts
openssl pkcs12 -in kibana.p12 -out kibana.crt -nodes
openssl pkcs12 -in kibana.p12 -out kibana.key -nodes -nocerts
openssl pkcs12 -in logstash.p12 -out logstash.crt -nodes
openssl pkcs12 -in logstash.p12 -out logstash.key -nodes -nocerts
```

All of these were put in secrets using SOPS.  
Configuration is then put in the helm values to use the correct certificates.

## Kibana

Create the encryption key :

```
encryptionkey=$(docker run --rm busybox:1.31.1 /bin/sh -c "< /dev/urandom tr -dc _A-Za-z0-9 | head -c50") && \
```

## Test

k port-forward svc/logstash-logstash 8080
curl -v -k --cert client.crt --key client.key -XPUT 'https://127.0.0.1:8080' -d 'hello'

(if ssl is disabled : curl -XPUT 'http://127.0.0.1:8080' -d 'hello')

in ES, data is indexed in a log datastream :
curl 127.0.0.1:9200/logs-generic-default/_search | jq
