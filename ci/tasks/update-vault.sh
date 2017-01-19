#!/bin/bash -e


vault write secret/bosh-$DEPLOYMENT_NAME-props \
  bosh-cacert=@rootCA.pem \
  bosh-pass==@director.pwd

