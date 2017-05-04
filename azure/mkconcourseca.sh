#!/usr/bin/env bash
BOSH=`which bosh2`

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int ./bosh-creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=boshadmin
export BOSH_DEPLOYMENT=concourse

${BOSH} -n -e boshadmin upload-stemcell \
	https://bosh.io/d/stemcells/bosh-azure-hyperv-ubuntu-trusty-go_agent?v=3363.20 \
	--sha1=e495b25e2bd4ce4c255846b6f8a3c7b652c42bb7

# Get a deployment running
${BOSH} -n deploy bootstrap-pcf/concourseca.yml -o bootstrap-pcf/azure/concourse-web-network.yml \
	--vars-store=./concourse-creds.yml \
	-l [MY FILLED OUT PARAM.YML]
