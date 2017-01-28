#!/bin/bash -e

chmod +x omg-cli/omg-linux

bosh_pass=$(vault read -field=bosh-pass secret/bosh-$DEPLOYMENT_NAME-props)

NETWORK_DNS_1=$PCF_MANAGEMENT_DNS
NETWORK_DNS_2=$PCF_SERVICES_DNS
NETWORK_DNS_3=$PCF_DEPLOYMENT_DNS

NETWORK_RESERVED_1=$PCF_MANAGEMENT_RESERVED
NETWORK_RESERVED_2=$PCF_SERVICES_RESERVED
NETWORK_RESERVED_3=$PCF_DEPLOYMENT_RESERVED

omg-cli/omg-linux register-plugin \
  --type cloudconfig \
  --pluginpath omg-cli/photon-cloudconfigplugin-linux

omg-cli/omg-linux deploy-cloudconfig \
  --bosh-url https://$BOSH_IP \
  --bosh-port 25555 \
  --bosh-user admin \
  --bosh-pass $bosh_pass \
  --ssl-ignore \
  photon-cloudconfigplugin-linux \
  --az az1 \
  --network-name-1 pcf-management \
  --network-az-1 az1 \
  --network-cidr-1 $PCF_MANAGEMENT_CIDR \
  --network-gateway-1 $PCF_MANAGEMENT_GATEWAY \
  --network-static-1 $PCF_MANAGEMENT_STATIC \
  --photon-network-name-1 $PCF_MANAGEMENT_PHOTON_ID \
  --network-name-2 pcf-services \
  --network-az-2 az1 \
  --network-cidr-2 $PCF_SERVICES_CIDR \
  --network-gateway-2 $PCF_SERVICES_GATEWAY \
  --network-static-2 $PCF_SERVICES_STATIC \
  --photon-network-name-2 $PCF_SERVICES_PHOTON_ID \
  --network-name-3 pcf-deployment \
  --network-az-3 az1 \
  --network-cidr-3 $PCF_DEPLOYMENT_CIDR \
  --network-gateway-3 $PCF_DEPLOYMENT_GATEWAY \
  --network-static-3 $PCF_DEPLOYMENT_STATIC \
  --photon-network-name-3 $PCF_DEPLOYMENT_PHOTON_ID 
