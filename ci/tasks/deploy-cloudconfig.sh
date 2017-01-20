#!/bin/bash -e

chmod +x omg-cli/omg-linux

bosh_pass=$(vault read -field=bosh-pass secret/bosh-$DEPLOYMENT_NAME-props || true)

pcf_management_dns=""
for i in $PCF_MANAGEMENT_DNS
do
  pcf_management_dns+="--network-dns-1 $i "
done

pcf_services_dns=""
for i in $PCF_SERVICES_DNS
do
  pcf_services_dns+="--network-dns-2 $i "
done

pcf_deployment_dns=""
for i in $PCF_DEPLOYMENT_DNS
do
  pcf_deployment_dns+="--network-dns-3 $i "
done

omg-cli/omg-linux register-plugin \
  --type cloudconfig \
  --pluginpath omg-cli/photon-cloudconfigplugin-linux

omg-cli/omg-linux deploy-cloudconfig \
  --bosh-url http://$BOSH_IP \
  --bosh-port 25555 \
  --bosh-user admin \
  --bosh-pass $bohsh_pass \
  --ssl-ignore \
  photon-cloudconfigplugin-linux \
  --az az1 \
  --network-name-1 pcf-management \
  --network-az-1 az1 \
  --network-cidr-1 $PCF_MANAGEMENT_CIDR \
  --network-gateway-1 $PCF_MANAGEMENT_GATEWAY \
  --network-dns-1 $PCF_MANAGEMENT_DNS \
  --network-reserved-1 $PCF_MANAGEMENT_RESERVED \
  --network-static-1 $PCF_MANAGEMENT_STATIC \
  --photon-network-name-1 $PCF_MANAGEMENT_PHOTON_ID \
  --network-name-2 pcf-services \
  --network-az-2 az1 \
  --network-cidr-2 $PCF_SERVICES_CIDR \
  --network-gateway-2 $PCF_SERVICES_GATEWAY \
  --network-dns-2 $PCF_SERVICES_DNS \
  --network-reserved-2 $PCF_SERVICES_RESERVED \
  --network-static-2 $PCF_SERVICES_STATIC \
  --photon-network-name-2 $PCF_SERVICES_PHOTON_ID \
  --network-name-3 pcf-deployment \
  --network-az-3 az1 \
  --network-cidr-3 $PCF_DEPLOYMENT_CIDR \
  --network-gateway-3 $PCF_DEPLOYMENT_GATEWAY \
  --network-dns-3 $PCF_DEPLOYMENT_DNS \
  --network-reserved-3 $PCF_DEPLOYMENT_RESERVED \
  --network-static-3 $PCF_DEPLOYMENT_STATIC \
  --photon-network-name-3 $PCF_DEPLOYMENT_PHOTON_ID 

