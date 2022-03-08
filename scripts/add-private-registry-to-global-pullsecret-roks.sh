#!/bin/bash


# https://www.ibm.com/docs/en/cloud-paks/cp-data/4.0?topic=tasks-configuring-your-cluster-pull-images
# https://cloud.ibm.com/docs/openshift?topic=openshift-registry#cluster_global_pull_secret

# Replace entitlement key with your actual entitlement key
# https://myibm.ibm.com/products-services/containerlibrary

oc create secret docker-registry pull-secret --docker-server=cp.icr.io --docker-username=cp --docker-password=${ENTITLEMENT_KEY} --dry-run=client --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode > myregistryconfigjson

# Retrieve the decoded secret value of the default global pull secret and store the value in a dockerconfigjson file.
oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode > dockerconfigjson

# Combine the downloaded private registry pull secret myregistryconfigjson file with the default global pull secret dockerconfigjson file.
jq -s '.[0] * .[1]' dockerconfigjson myregistryconfigjson > dockerconfigjson-merged

# Update the global pull secret with the combined dockerconfigjson-merged file.
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfigjson-merged

# Verify that the global pull secret is updated. Check that your private registry and each of the default Red Hat registries are in the output of the following command.
oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode

rm dockerconfigjson
rm myregistryconfigjson

echo 'For IBM Cloud,'
echo 'To pick up the global configuration changes,'
echo 'reload all the worker nodes in your cluster.'
echo 'ibmcloud oc worker ls -c CLUSTER_ID'
echo 'ibmcloud ks worker reload --cluster CLUSTER_ID -w WORKER_ID_1 -w WORKER_ID_2'
echo 'Example: '
echo 'jq \'"ibmcloud ks worker reload --cluster CLUSTER_ID -w \(.[] | .id)"\''