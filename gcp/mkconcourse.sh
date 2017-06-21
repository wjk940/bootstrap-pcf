#!/usr/bin/env bash
BOSH=`which bosh2`

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 interpolate ./creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=boshadmin
export BOSH_DEPLOYMENT=concourse

${BOSH} -n -e boshadmin upload-stemcell \
	https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=3421.9 \
	--sha1=b1866e2dad3b8d0307be38f4e1dd82ccde722b36

# Get a deployment running
${BOSH} -n deploy bootstrap-pcf/concourse.yml \
	--ops-file=bootstrap-pcf/gcp/concourse-web-network.yml \
	--vars-file=[MY FILLED OUT PARAM.YML]
