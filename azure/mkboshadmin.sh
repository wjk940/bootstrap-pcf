#!/usr/bin/env bash
BOSH=`which bosh2`
BOSH_DEPLOYMENT=bosh-deployment

# Deploy a Director -- ./bosh-creds.yml is generated automatically
echo "create-env"
${BOSH} create-env ${BOSH_DEPLOYMENT}/bosh.yml \
  --state ./state.json \
  -o ${BOSH_DEPLOYMENT}/azure/cpi.yml \
  --vars-store ./bosh-creds.yml \
  -l [MY FILLED OUT PARAM.YML]

export BOSH_ENVIRONMENT=boshadmin

# Alias deployed Director
echo "alias-env"
${BOSH} -e 10.0.0.8 --ca-cert <(${BOSH} int ./bosh-creds.yml --path /director_ssl/ca) alias-env ${BOSH_ENVIRONMENT}

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`${BOSH} int ./bosh-creds.yml --path /admin_password`

# Update cloud config -- single az
echo "update-cloud-config"
${BOSH} -n update-cloud-config ${BOSH_DEPLOYMENT}/azure/cloud-config.yml \
  -l [MY FILLED OUT PARAM.YML]
