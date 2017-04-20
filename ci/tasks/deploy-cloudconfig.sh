#!/bin/bash -e

export BOSH_ENVIRONMENT=$(vault read -field=bosh-url secret/bosh-$FOUNDATION_NAME-props)
export BOSH_CLIENT=$(vault read -field=bosh-client-id secret/bosh-$FOUNDATION_NAME-props)
export BOSH_CLIENT_SECRET=$(vault read -field=bosh-client-secret secret/bosh-$FOUNDATION_NAME-props)
export BOSH_CA_CERT=$(vault read -field=bosh-cacert secret/bosh-$FOUNDATION_NAME-props)

bosh interpolate concourse-deploy-bosh/ci/templates/cloud-config.yml \
  -v pcf-management-network=$PCF_MANAGEMENT_PHOTON_ID \
  -v pcf-management-dns=[$PCF_MANAGEMENT_DNS] \
  -v pcf-management-gateway=$PCF_MANAGEMENT_GATEWAY \
  -v pcf-management-cidr=$PCF_MANAGEMENT_CIDR \
  -v pcf-management-reserved=$PCF_MANAGEMENT_RESERVED \
  -v pcf-management-static=$PCF_MANAGEMENT_STATIC \
  -v pcf-services-network=$PCF_SERVICES_PHOTON_ID \
  -v pcf-services-dns=[$PCF_SERVICES_DNS] \
  -v pcf-services-gateway=$PCF_SERVICES_GATEWAY \
  -v pcf-services-cidr=$PCF_SERVICES_CIDR \
  -v pcf-services-reserved=$PCF_SERVICES_RESERVED \
  -v pcf-services-static=$PCF_SERVICES_STATIC \
  -v pcf-deployment-network=$PCF_DEPLOYMENT_PHOTON_ID \
  -v pcf-deployment-dns=[$PCF_DEPLOYMENT_DNS] \
  -v pcf-deployment-gateway=$PCF_DEPLOYMENT_GATEWAY \
  -v pcf-deployment-cidr=$PCF_DEPLOYMENT_CIDR \
  -v pcf-deployment-reserved=$PCF_DEPLOYMENT_RESERVED \
  -v pcf-deployment-static=$PCF_DEPLOYMENT_STATIC  > cc.yml

bosh -n update-cloud-config cc.yml
