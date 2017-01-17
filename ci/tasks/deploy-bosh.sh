#!/bin/bash -e

chmod +x omg-cli/omg-linux

sha1=$(sha1sum bosh-photon-cpi/release.tgz)

dns=""
for i in $PCF_MANAGEMENT_DNS
do
  dns+="--dns $i "
done

omg-cli/omg-linux photon   \   
  --mode uaa   \   
  --cidr $PCF_MANAGEMENT_CIDR   \   
  --gateway $PCF_MANAGEMENT_GATEWAY   \   
  $dns \
  --bosh-private-ip $BOSH_IP   \   
  --bosh-cpi-release-url "file://bosh-photon-cpi/release.tgz"   \   
  --bosh-cpi-release-sha $sha1   \   
  --director-name $DIRECTOR_NAME   \   
  --photon-target $PHOTON_URL   \   
  --photon-user $PHOTON_USER   \   
  --photon-password $PHOTON_PASSWORD   \   
  --photon-ignore-cert \
  --photon-project-id $PHOTON_PROJECT \
  --photon-network-id $PCF_MANAGEMENT_PHOTON_ID \
  --ntp-server $NTP_SERVER \
