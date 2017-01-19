#!/bin/bash -e


vault write ${VAULT_PROPERTIES_PATH} \
  bosh-cacert=@rootCA.pem \
  bosh-pass==@director.pwd

