#!/usr/bin/env bash
BOSH=`which bosh2`

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int ./creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=boshadmin
export BOSH_DEPLOYMENT=concourse

${BOSH} -n -e boshadmin upload-stemcell \
	https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent?v=3363.20 \
	--sha1=cc46c54c4b93dc0933bf9139b60d6782ffcad7ef

# Get a deployment running
${BOSH} -n deploy bootstrap-pcf/concourse.yml -o bootstrap-pcf/azure/concourse-web-network.yml \
	-l [MY FILLED OUT PARAM.YML]
