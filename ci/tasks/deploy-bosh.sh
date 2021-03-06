#!/bin/bash -e

chmod +x omg-cli/omg-linux

sha1=$(sha1sum bosh-photon-cpi/release.tgz | awk '{print $1}')

nats_pass=$(vault read -field=nats-pass secret/bosh-$FOUNDATION_NAME-props || true)

if [ "$nats_pass" ]; then
  nats="--nats-pwd $nats_pass"
fi

bosh_state=$(vault read -field=bosh-state secret/bosh-$FOUNDATION_NAME-props || true)

if [ "$bosh_state" ]; then
  echo $bosh_state > omg-bosh-state.json
fi

export DNS=$PCF_MANAGEMENT_DNS

cmd='omg-cli/omg-linux photon \
  --mode uaa \
  --cidr $PCF_MANAGEMENT_CIDR \
  --gateway $PCF_MANAGEMENT_GATEWAY \
  --bosh-private-ip $BOSH_IP \
  --bosh-cpi-release-url "file://bosh-photon-cpi/release.tgz" \
  --bosh-cpi-release-sha $sha1 \
  --director-name bosh-$FOUNDATION_NAME \
  --photon-target $PHOTON_URL \
  --photon-project-id $PHOTON_PROJECT_ID \
  --photon-network-id $PCF_MANAGEMENT_PHOTON_ID \
  --photon-user $PHOTON_USER \
  --photon-password "$PHOTON_PASSWORD" \
  --ntp-server $NTP_SERVER \
  --photon-ignore-cert \
  $nats' 

eval "$cmd --print-manifest > manifest.yml"
eval "$cmd"


vault write secret/bosh-$FOUNDATION_NAME-props \
  bosh-cacert=@rootCA.pem \
  bosh-pass=@director.pwd \
  nats-pass=@nats.pwd \
  bosh-state=@omg-bosh-state.json \
  bosh-port=25555 \
  bosh-client-id=director \
  bosh-client-secret=@director.pwd \
  bosh-url="https://$BOSH_IP" \
  bosh-user=director \
  bosh-manifest=@manifest.yml

