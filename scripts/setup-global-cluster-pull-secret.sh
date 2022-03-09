#!/usr/bin/env bash

echo $PULL_SECRET

oc create secret docker-registry pull-secret --docker-server=cp.icr.io --docker-username=cp --docker-password=$PULL_SECRET --dry-run=client --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode > myregistryconfigjson

oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode > dockerconfigjson

jq -s '.[0] * .[1]' dockerconfigjson myregistryconfigjson > dockerconfigjson-merged

oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfigjson-merged

oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode | jq

rm dockerconfigjson
rm dockerconfigjson-merged
rm myregistryconfigjson