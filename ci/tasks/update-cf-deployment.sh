#!/bin/bash -e


all_ips=$(prips $(echo "$PCF_DEPLOYMENT_STATIC" | sed 's/-/ /'))
OLD_IFS=$IFS
IFS=$'\n'
all_ips=($all_ips)
IFS=$OLD_IFS
new_ips=()
for value in "${all_ips[@]}"
do
    [[ $value != $HAPROXY_IP ]] && new_ips+=($value)
done

echo "0" > index
get_ips(){
  index=$(cat index)
  res=""
  new_index=$(($index + $1))
  for ((i = $index; i < $new_index; i++))
  do
    res="$res,${new_ips[$i]}"
  done
  echo "$new_index" > index
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
uaa-ldap-password: $UAA_LDAP_PASSWORD
vault-json-string: |
  {
    "app-domain": "$APP_DOMAIN",
    "bosh-port": "25555",
    "bosh-url": "https://$BOSH_IP",
    "bosh-user": "admin",
    "router-ip": "$(get_ips 4)", #gorouter should be on top, as the first 4 ips are reserved for the gorouter
    "router-vm-type": "large.memory",
    "cc-vm-type": "large.memory",
    "cc-worker-vm-type": "large.memory",
    "clock-global-vm-type": "large.memory",
    "consul-ip": "$(get_ips 3)",
    "consul-vm-type": "large.memory",
    "diego-brain-disk-type": "large",
    "diego-brain-ip": "$(get_ips 3)",
    "diego-brain-vm-type": "large.memory",
    "diego-cell-disk-type": "large",
    "diego-cell-ip": "$(get_ips 7)",
    "diego-cell-vm-type": "large.memory",
    "diego-db-ip": "$(get_ips 3)",
    "diego-db-vm-type": "large.memory",
    "deployment-name": "cf-$DEPLOYMENT_NAME",
    "doppler-ip": "$(get_ips 3)",
    "doppler-vm-type": "large.memory",
    "errand-vm-type": "large.memory",
    "etcd-machine-ip": "$(get_ips 3)",
    "etcd-vm-type": "large.memory",
    "haproxy-vm-type": "large.memory",
    "haproxy-ip": "$HAPROXY_IP",
    "skip-haproxy": "false",
    "loggregator-traffic-controller-ip": "$(get_ips 3)",
    "loggregator-traffic-controller-vmtype": "large.memory",
    "mysql-disk-type": "large",
    "mysql-ip": "$(get_ips 3)",
    "mysql-proxy-ip": "$(get_ips 3)",
    "mysql-proxy-vm-type": "large.memory",
    "mysql-vm-type": "large.memory",
    "nats-machine-ip": "$(get_ips 3)",
    "nats-vm-type": "large.memory",
    "nfs-allow-from-network-cidr": "$PCF_DEPLOYMENT_CIDR",
    "nfs-disk-type": "large",
    "nfs-ip": "$(get_ips 1)",
    "nfs-vm-type": "large.memory",
    "system-domain": "$SYSTEM_DOMAIN",
    "uaa-vm-type": "large.memory",
    "uaa-ldap-enabled": "true",
    "uaa-ldap-url": "$UAA_LDAP_URL",
    "uaa-ldap-user-dn": "$UAA_LDAP_USER_DN",
    "uaa-ldap-search-base": "$UAA_LDAP_SEARCH_BASE",
    "uaa-ldap-search-filter": "$UAA_LDAP_SEARCH_FILTER",
    "uaa-ldap-mail-attributename": "$UAA_LADP_MAIL_ATTRIBUTENAME",
    "allow-app-ssh-access": "true"
  }
EOF

fly -t cp login -c $CONCOURSE_URL -u $CONCOURSE_USER -p $CONCOURSE_PASSWORD
fly -t cp set-pipeline -n  -p deploy-cf-$DEPLOYMENT_NAME  -c concourse-deploy-cloudfoundry/ci/pcf-pipeline.yml -l pcf-pipeline-vars.yml
