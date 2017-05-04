#!/usr/bin/env bash
BOSH=`which bosh2`

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int ./creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=boshadmin
export BOSH_DEPLOYMENT=concourse

${BOSH} -n -e boshadmin upload-stemcell \
	https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=3363.20 \
	--sha1=0b107fe9a9b29f0fb74d84d5a46d1ba04d3b7647

# Get a deployment running
${BOSH} -n deploy bootstrap-pcf/concourse.yml -o bootstrap-pcf/azure/concourse-web-network.yml \
	-l [MY FILLED OUT PARAM.YML]
