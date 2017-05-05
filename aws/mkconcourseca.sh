#!/usr/bin/env bash
BOSH=`which bosh2`

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 interpolate ./bosh-creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=boshadmin
export BOSH_DEPLOYMENT=concourse

${BOSH} -n -e boshadmin upload-stemcell \
	https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent?v=3363.20 \
	--sha1=dc0ac0443728638e4aa1d4a8d25942989a9853d3

# Get a deployment running
${BOSH} -n deploy bootstrap-pcf/concourse.yml \
	--ops-file=bootstrap-pcf/aws/concourse-web-network.yml \
	--ops-file=bootstrap-pcf/concourse-bosh-ca.yml \
	--vars-store=./concourse-creds.yml \
	--vars-file=[MY FILLED OUT PARAM.YML]
