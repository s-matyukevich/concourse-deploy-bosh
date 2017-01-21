#!/bin/bash -e

all_ips=$(prips $(echo "$PCF_DEPLOYMENT_STATIC" | sed 's/-/ /'))
IFS=$'\n'
all_ips=($all_ips)
delete=($HAPROXY_IP)
array=( "${all_ips[@]/$delete}" )


get_ips(){
  res=""
  for ((i = $1; i <= $2; i++))
  do
    res="$res,${all_ips[$index]}"
  done
  echo "$res" | cut -c 2-
}

bosh_pass=$(vault read -field=bosh-pass secret/bosh-$DEPLOYMENT_NAME-props)
bosh_cacert=$(vault read -field=bosh-cacert secret/bosh-$DEPLOYMENT_NAME-props)

cat > pcf-pipeline-vars.yml <<EOF
bosh-cacert: |
$(echo "$bosh_cacert" | sed 's/^/  /')
bosh-client-id: director
bosh-client-secret: $bosh_pass
bosh-pass: $bosh_pass
bosh-url: https://$BOSH_IP
bosh-user: admin
app-domain: $APP_DOMAIN
system-domain: $SYSTEM_DOMAIN
concourse-url: $CONCOURSE_URL
concourse-user: $CONCOURSE_USER
concourse-pass: $CONCOURSE_PASSWORD
deployment-name: cf-$DEPLOYMENT_NAME
product-slug: $PRODUCT_SLUG
product-version: $PRODUCT_VERSION
product-plugin: $PRODUCT_PLUGIN
pivnet-api-token: $PIVNET_API_TOKEN
skip-haproxy: $SKIP_HAPROXY
stemcell-cpi-glob: '$STEMCELL_CPI_GLOB'
stemcell-version: $STEMCELL_VERSION
vault-addr: $VAULT_ADDR
vault-hash-hostvars: secret/cf-$DEPLOYMENT_NAME-hostvars
vault-hash-ip: secret/cf-$DEPLOYMENT_NAME-ip
vault-hash-keycert: secret/cf-$DEPLOYMENT_NAME-keycert
vault-hash-misc: secret/cf-$DEPLOYMENT_NAME-props
vault-hash-password: secret/cf-$DEPLOYMENT_NAME-password
vault-token: $VAULT_TOKEN
vault-json-string: |
  {
    "allow-app-ssh-access": "true",
    "system-domain": "$SYSTEM_DOMAIN",
    "app-domain": "$APP_DOMAIN",
    "bosh-port": "25555",
    "bosh-url": "https://$BOSH_IP",
    "bosh-user": "admin",
    "cc-vm-type": "large",
    "cc-worker-vm-type": "large",
    "clock-global-vm-type": "large",
    "consul-ip": "$(get_ips 0 2)",
    "consul-vm-type": "large",
    "diego-brain-disk-type": "51200",
    "diego-brain-ip": "$(get_ips 3 5)",
    "diego-brain-vm-type": "large",
    "diego-cell-disk-type": "51200",
    "diego-cell-ip": "$(get_ips 6 12)",
    "diego-cell-vm-type": "large",
    "diego-db-ip": "$(get_ips 13 15)",
    "diego-db-vm-type": "large",
    "deployment-name": "cf-nonprod",
    "doppler-ip": "$(get_ips 16 18)",
    "doppler-vm-type": "large",
    "errand-vm-type": "large",
    "etcd-machine-ip": "$(get_ips 19 21)",
    "etcd-vm-type": "large",
    "haproxy-vm-type": "large",
    "haproxy-ip": "$HAPROXY_IP",
    "loggregator-traffic-controller-ip": "",
    "loggregator-traffic-controller-vmtype": "large",
    "mysql-disk-type": "51200",
    "mysql-ip": "$(get_ips 22 24)",
    "mysql-proxy-ip": "$(get_ips 25 27)",
    "mysql-proxy-vm-type": "large",
    "mysql-vm-type": "large",
    "nats-machine-ip": "$(get_ips 28 30)",
    "nats-vm-type": "large",
    "nfs-allow-from-network-cidr": "",
    "nfs-disk-type": "51200",
    "nfs-ip": "$(get_ips 31 33)",
    "nfs-vm-type": "large",
    "router-ip": "$(get_ips 34 36)",
    "router-vm-type": "large",
    "uaa-vm-type": "large",
    "syslog-address": "$SYSLOG_ADDRESS"
  }
EOF

fly -t cp login -c $CONCOURSE_URL -u $CONCOURSE_USER -p $CONCOURSE_PASSWORD
fly -t cp set-pipeline -n  -p deploy-cf-$DEPLOYMENT_NAME  -c concourse-deploy-cloudfoundry/ci/pcf-pipeline.yml -l pcf-pipeline-vars.yml
