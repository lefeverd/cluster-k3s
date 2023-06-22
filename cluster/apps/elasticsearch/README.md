# ELK

## Elasticsearch configuration

The creation of settings and mappings is done through a `postExec` hook in the elasticsearch helm configuration.  
The downside is that the pod stays longer in `PodInitializing`, as the hook waits for elastic to be up and running.  
Thus we can't really see elastic's logs until the hook finishes.

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

To generate new certificates, export the elastic-ca p12 from the secret.

## Kibana

Create the encryption key :

```
encryptionkey=$(docker run --rm busybox:1.31.1 /bin/sh -c "< /dev/urandom tr -dc _A-Za-z0-9 | head -c50") && \
```

## Test

### Locally

You can logstash's pipelines locally first.  
Copy them in the pipeline/logstash.conf file, then use docker :

```
docker run --rm -it -p 8080:8080 -v $(pwd)/pipeline/:/usr/share/logstash/pipeline/ docker.elastic.co/logstash/logstash:7.17.6
```

You can then send a test event :

```
curl -XPUT 127.0.0.1:8080 -d @borgmatic-output.txt
```

### Using kubernetes with port-forward

k port-forward svc/logstash-logstash 8080&
curl -v -k --cert logstash.crt --key logstash.key -XPUT 'https://127.0.0.1:8080' -d @borgmatic-output.txt
kill %1

With test data instead of file content :
curl -v -k --cert logstash.crt --key logstash.key -XPUT 'https://127.0.0.1:8080' -d 'hello'

(if ssl is disabled : curl -XPUT 'http://127.0.0.1:8080' -d 'hello')

in ES, data is indexed in a log datastream :
kubectl port-forward svc/elasticsearch-master 9200
curl 127.0.0.1:9200/logs-generic-default/_search | jq

### Using kibana

You can test to index a document directly in Kibana (so without logstash's transformations).  
You can use the dev tools, and execute :

```
POST logs-backup-default/_doc
{
    "document": {
      "end": "2023-06-07T18:31:33.000000",
      "id": "23c04c2fded1a65446750fb2fa1facd6f876550a95c03583b6fee60ba7d0b9b8",
      "username": "dvd",
      "name": "fedora-2023-06-07T18:22:23.038764",
      "comment": "",
      "backup_name": "home",
      "duration": 525.113209,
      "stats": {
        "nfiles": 771671,
        "original_size": 188328514232,
        "original_size_mb": 179604,
        "deduplicated_size_mb": 185,
        "compressed_size": 135940319653,
        "compressed_size_mb": 129642,
        "deduplicated_size": 194576003
      },
      "command_line": [
        "/usr/bin/borg",
        "create",
        "--patterns-from",
        "/tmp/tmp82fxt5w2",
        "--exclude-from",
        "/tmp/tmp90qm3vwt",
        "ssh://synoborg/./dvd-fedora-home::{hostname}-{now:%Y-%m-%dT%H:%M:%S.%f}",
        "--info"
      ],
      "limits": {
        "max_archive_size": 0.0032176080666509025
      },
      "start": "2023-06-07T18:22:48.000000",
      "hostname": "fedora"
    },
    "url": {
      "domain": "logstash.dhosting.xyz",
      "path": "/http"
    },
    "host": {
      "ip": "10.42.152.196"
    },
    "@timestamp": "2023-06-07T16:33:33.000Z",
    "@version": "1",
    "http": {
      "method": "PUT",
      "request": {
        "mime_type": "application/json",
        "body": {
          "bytes": "814"
        }
      },
      "version": "HTTP/1.1"
    },
    "user_agent": {
      "original": "curl/7.85.0"
    },
    "start_date": "2023-06-07T16:22:48.000Z",
    "end_date": "2023-06-07T16:31:33.000Z",
    "event": {
      "original": "{  \"chunker_params\": [    \"buzhash\",    19,    23,    21,    4095  ],  \"command_line\": [    \"/usr/bin/borg\",    \"create\",    \"--patterns-from\",    \"/tmp/tmp82fxt5w2\",    \"--exclude-from\",    \"/tmp/tmp90qm3vwt\",    \"ssh://synoborg/./dvd-fedora-home::{hostname}-{now:%Y-%m-%dT%H:%M:%S.%f}\",    \"--info\"  ],  \"comment\": \"\",  \"duration\": 525.113209,  \"end\": \"2023-06-07T18:31:33.000000\",  \"hostname\": \"fedora\",  \"id\": \"23c04c2fded1a65446750fb2fa1facd6f876550a95c03583b6fee60ba7d0b9b8\",  \"limits\": {    \"max_archive_size\": 0.0032176080666509025  },  \"name\": \"fedora-2023-06-07T18:22:23.038764\",  \"start\": \"2023-06-07T18:22:48.000000\",  \"stats\": {    \"compressed_size\": 135940319653,    \"deduplicated_size\": 194576003,    \"nfiles\": 771671,    \"original_size\": 188328514232  },  \"username\": \"dvd\",  \"backup_name\": \"home\"}"
    }
  }
```
