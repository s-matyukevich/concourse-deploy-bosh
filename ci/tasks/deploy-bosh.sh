#!/bin/bash -e

chmod +x omg-cli/omg-linux

sha1=$(sha1sum bosh-photon-cpi/release.tgz | awk '{print $1}')

nats_pass=$(vault read -field=nats-pass secret/bosh-$DEPLOYMENT_NAME-props || true)

if [ $nats_pass]; then
  nats="--nats-pwd $nats_pass"
fi

bosh_state=$(vault read -field=bosh-state secret/bosh-$DEPLOYMENT_NAME-props || true)

if [ "$bosh_state" ]; then
  echo $bosh_state > omg-bosh-state.json
fi

OMG_DNS=$PCF_MANAGEMENT_DNS

omg-cli/omg-linux photon \
  --mode uaa \
  --cidr $PCF_MANAGEMENT_CIDR \
  --gateway $PCF_MANAGEMENT_GATEWAY \
  --bosh-private-ip $BOSH_IP \
  --bosh-cpi-release-url "file://bosh-photon-cpi/release.tgz" \
  --bosh-cpi-release-sha $sha1 \
  --director-name bosh-$DEPLOYMENT_NAME \
  --photon-target $PHOTON_URL \
  --photon-project-id $PHOTON_PROJECT_ID \
  --photon-network-id $PCF_MANAGEMENT_PHOTON_ID \
  --photon-user $PHOTON_USER \
  --photon-password "$PHOTON_PASSWORD" \
  --ntp-server $NTP_SERVER \
  --photon-ignore-cert \
  $nats

vault write secret/bosh-$DEPLOYMENT_NAME-props \
  bosh-cacert=@rootCA.pem \
  bosh-pass=@director.pwd \
  nats-pass=@nats.pwd \
  bosh-state=@omg-bosh-state.json

