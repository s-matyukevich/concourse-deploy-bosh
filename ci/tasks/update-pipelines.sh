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

bosh_pass=$(vault read -field=bosh-pass secret/bosh-$FOUNDATION_NAME-props)
bosh_client_id=$(vault read -field=bosh-client-id secret/bosh-$FOUNDATION_NAME-props)
bosh_client_secret=$(vault read -field=bosh-client-secret secret/bosh-$FOUNDATION_NAME-props)
bosh_cacert=$(vault read -field=bosh-cacert secret/bosh-$FOUNDATION_NAME-props)

cat > pcf-pipeline-vars.yml <<EOF
git-private-key: |
$(echo "$GIT_PRIVATE_KEY" | sed 's/^/  /')
deploy-cloudfoundry-git-url: $DEPLOY_CLOUDFOUNDRY_GIT_URL
deploy-redis-git-url: $DEPLOY_REDIS_GIT_URL
deploy-p-mysql-git-url: $DEPLOY_P_MYSQL_GIT_URL
deploy-turbulence-git-url: $DEPLOY_TURBULENCE_GIT_URL
deploy-chaos-loris-git-url: $DEPLOY_CHAOS_LORIS_GIT_URL
deploy-rabbitmq-git-url: $DEPLOY_RABBITMQ_GIT_URL
deploy-mgmt-git-url: $DEPLOY_MGMT_GIT_URL
deploy-bluemedora-git-url: $DEPLOY_BLUEMEDORA_GIT_URL 
deploy-firehose-to-loginsight-git-url: $DEPLOY_FIREHOSE_TO_LOGINSIGHT_GIT_URL
deploy-spring-services-git-url: $DEPLOY_SPRING_SERVICES_GIT_URL 
bosh-cacert: |
$(echo "$bosh_cacert" | sed 's/^/  /')
bosh-client-id: director
bosh-client-secret: $bosh_pass
bosh-pass: $bosh_pass
bosh-url: https://$BOSH_IP
bosh-user: admin
syslog-address: $SYSLOG_ADDRESS
app-domain: $APP_DOMAIN
system-domain: $SYSTEM_DOMAIN
concourse-url: $CONCOURSE_URL
concourse-user: $CONCOURSE_USER
concourse-pass: $CONCOURSE_PASSWORD
deployment-name: cf-$FOUNDATION_NAME
foundation-name: $FOUNDATION_NAME
product-slug: $PRODUCT_SLUG
product-version: $PRODUCT_VERSION
product-plugin: $PRODUCT_PLUGIN
pivnet-api-token: $PIVNET_API_TOKEN
skip-haproxy: $SKIP_HAPROXY
stemcell-cpi-glob: '$STEMCELL_CPI_GLOB'
stemcell-version: $STEMCELL_VERSION
vault-addr: $VAULT_ADDR
vault-hash-hostvars: secret/cf-$FOUNDATION_NAME-hostvars
vault-hash-ip: secret/cf-$FOUNDATION_NAME-ip
vault-hash-keycert: secret/cf-$FOUNDATION_NAME-keycert
vault-hash-misc: secret/cf-$FOUNDATION_NAME-props
vault-hash-password: secret/cf-$FOUNDATION_NAME-password
vault-token: $VAULT_TOKEN
uaa-ldap-password: $UAA_LDAP_PASSWORD
pcf-services-static: $PCF_SERVICES_STATIC
configserver-git-repo-url: $CONFIGSERVER_GIT_REPO_URL
configserver-git-repo-user: $CONFIGSERVER_GIT_REPO_USERNAME
configserver-git-repo-password: $CONFIGSERVER_GIT_REPO_PASSWORD
vault-json-string: |
  {
    "app-domain": "$APP_DOMAIN",
    "bosh-port": "25555",
    "bosh-url": "https://$BOSH_IP",
    "bosh-user": "admin",
    "router-ip": "$(get_ips 4)", 
    "router-vm-type": "small",
    "cc-vm-type": "small",
    "cc-worker-vm-type": "small",
    "clock-global-vm-type": "small",
    "consul-ip": "$(get_ips 3)",
    "consul-vm-type": "small",
    "diego-brain-disk-type": "large",
    "diego-brain-ip": "$(get_ips 3)",
    "diego-brain-vm-type": "small",
    "diego-cell-disk-type": "large",
    "diego-cell-ip": "$(get_ips 7)",
    "diego-cell-vm-type": "medium",
    "diego-db-ip": "$(get_ips 3)",
    "diego-db-vm-type": "small",
    "deployment-name": "cf-$FOUNDATION_NAME",
    "doppler-ip": "$(get_ips 3)",
    "doppler-vm-type": "small",
    "errand-vm-type": "small",
    "etcd-machine-ip": "$(get_ips 3)",
    "etcd-vm-type": "small",
    "haproxy-vm-type": "small",
    "haproxy-ip": "$HAPROXY_IP",
    "skip-haproxy": "false",
    "loggregator-traffic-controller-ip": "$(get_ips 3)",
    "loggregator-traffic-controller-vmtype": "small",
    "mysql-disk-type": "large",
    "mysql-ip": "$(get_ips 3)",
    "mysql-proxy-ip": "$(get_ips 3)",
    "mysql-proxy-vm-type": "small",
    "mysql-vm-type": "small",
    "nats-machine-ip": "$(get_ips 3)",
    "nats-vm-type": "small",
    "nfs-allow-from-network-cidr": "$PCF_DEPLOYMENT_CIDR",
    "nfs-disk-type": "large",
    "nfs-ip": "$(get_ips 1)",
    "nfs-vm-type": "small",
    "system-domain": "$SYSTEM_DOMAIN",
    "uaa-vm-type": "small",
    "uaa-ldap-enabled": "true",
    "uaa-ldap-url": "$UAA_LDAP_URL",
    "uaa-ldap-user-dn": "$UAA_LDAP_USER_DN",
    "uaa-ldap-search-base": "$UAA_LDAP_SEARCH_BASE",
    "uaa-ldap-search-filter": "$UAA_LDAP_SEARCH_FILTER",
    "uaa-ldap-mail-attributename": "$UAA_LADP_MAIL_ATTRIBUTENAME",
    "allow-app-ssh-access": "true"
  }
EOF

fly -t $FOUNDATION_NAME login  -n  $FOUNDATION_NAME -c $CONCOURSE_URL -u $CONCOURSE_USER -p $CONCOURSE_PASSWORD
fly -t $FOUNDATION_NAME set-pipeline -n  -p deploy-cf -c concourse-deploy-cloudfoundry/ci/pcf-pipeline.yml -l pcf-pipeline-vars.yml

cat > backup-pipeline-vars.yml <<EOF
git-private-key: |
$(echo "$GIT_PRIVATE_KEY" | sed 's/^/  /')
bosh-backup-git-url: $BOSH_BACKUP_GIT_URL
bosh-pass: $bosh_pass
bosh-url: https://$BOSH_IP
bosh-user: admin
bosh-cacert: |
$(echo "$bosh_cacert" | sed 's/^/  /')
store-host: $BOSH_BACKUP_STORE_HOST
store-user: $BOSH_BACKUP_STORE_USER
store-password: $BOSH_BACKUP_STORE_PASSWORD
store-path: $BOSH_BACKUP_STORE_PATH
EOF

fly -t $FOUNDATION_NAME set-pipeline -n  -p bosh-backup -c bosh-backup/ci/pipeline.yml -l backup-pipeline-vars.yml
