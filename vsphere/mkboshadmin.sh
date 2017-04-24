#!/usr/bin/env bash
BOSH=`which bosh2`
BOSH_DEPLOYMENT=bosh-deployment

# Deploy a Director -- ./creds.yml is generated automatically
echo "create-env"
${BOSH} create-env ${BOSH_DEPLOYMENT}/bosh.yml \
  --state ./state.json \
  -o ${BOSH_DEPLOYMENT}/vsphere/cpi.yml \
  --vars-store ./creds.yml \
  -l  ./bootstrap-pcf.yml

export BOSH_ENVIRONMENT=boshadmin

# Alias deployed Director
echo "alias-env"
${BOSH} -e bosh.ops.wjkeenan.net --ca-cert <(${BOSH} int ./creds.yml --path /director_ssl/ca) alias-env ${BOSH_ENVIRONMENT}

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`${BOSH} int ./creds.yml --path /admin_password`

# Update cloud config -- single az
echo "update-cloud-config"
${BOSH} -n update-cloud-config ${BOSH_DEPLOYMENT}/vsphere/cloud-config.yml \
  -l  ./bootstrap-pcf.yml
