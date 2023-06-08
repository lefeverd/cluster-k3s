#!/bin/bash
#
# This script creates some objects in elasticsearch in order to configure the ingestion of backup logs.
# See https://www.elastic.co/guide/en/elasticsearch/reference/current/set-up-a-data-stream.html
#

ES_URL=https://localhost:9200

echo "Creating ILM policy for backup logs"
curl -k -u elastic:$ELASTIC_PASSWORD -XPUT "$ES_URL/_ilm/policy/backup-logs-policy" -H 'Content-Type: application/json' -d@/configuration/ilm-backup-logs.json

echo "Creating mappings for backup logs"
curl -k -u elastic:$ELASTIC_PASSWORD -XPUT "$ES_URL/_component_template/backup-logs-mappings" -H 'Content-Type: application/json' -d@/configuration/mapping-backup-logs.json

echo "Creating settings for backup logs"
curl -k -u elastic:$ELASTIC_PASSWORD -XPUT "$ES_URL/_component_template/backup-logs-settings" -H 'Content-Type: application/json' -d@/configuration/settings-backup-logs.json

echo "Creating index template for backup logs"
curl -k -u elastic:$ELASTIC_PASSWORD -XPUT "$ES_URL/_index_template/backup-logs-template" -H 'Content-Type: application/json' -d@/configuration/template-backup-logs.json
