#!/bin/bash
. $(dirname ${BASH_SOURCE})/util.sh

runc 'oc policy add-role-to-user edit system:serviceaccount:ci-cd:jenkins -n dev'
runc 'oc policy add-role-to-group system:image-puller system:serviceaccounts:ci-cd -n dev'
runc 'oc policy add-role-to-user edit system:serviceaccount:ci-cd:jenkins -n qa'
runc 'oc policy add-role-to-group system:image-puller system:serviceaccounts:ci-cd -n qa'
runc 'oc policy add-role-to-group system:image-puller system:serviceaccounts:qa -n dev'
runc 'oc create -f https://raw.githubusercontent.com/debianmaster/istio-openshift-example/master/pipeline.yaml'

