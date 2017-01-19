#!/bin/bash 

chmod +x omg-cli/omg-linux

sha1=$(sha1sum bosh-photon-cpi/release.tgz)

nats_pass=$(vault read -field=nats-pass secret/bosh-$DEPLOYMENT_NAME-props || true)

if [ -n $nats_pass]; then
  nats="--nats-pwd $nats_pass"
fi

omg-cli/omg-linux photon \
  --mode uaa \
  --cidr $PCF_MANAGEMENT_CIDR \
  --gateway $PCF_MANAGEMENT_GATEWAY \
  --dns $PCF_MANAGEMENT_DNS \
  --bosh-private-ip $BOSH_IP \
  --bosh-cpi-release-url "file://bosh-photon-cpi/release.tgz" \
  --bosh-cpi-release-sha $sha1 \
  --director-name bosh-$DEPLOYMENT_NAME \
  --photon-target $PHOTON_URL \
  --photon-user $PHOTON_USER \
  --photon-password $PHOTON_PASSWORD \
  --photon-ignore-cert \
  --photon-project-id $PHOTON_PROJECT \
  --photon-network-id $PCF_MANAGEMENT_PHOTON_ID \
  --ntp-server $NTP_SERVER \
  $nats

