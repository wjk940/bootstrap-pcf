#!/usr/bin/env bash
BOSH=`which bosh2`

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int ./creds.yml --path /admin_password`
export BOSH_ENVIRONMENT=boshadmin
export BOSH_DEPLOYMENT=concourse

${BOSH} -n -e boshadmin upload-stemcell \
	http://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent?v=3363.15 \
	--sha1=d5571cd8e13d1daca99dc821e4fb751f4cdd42f8

# Get a deployment running
${BOSH} -n deploy bootstrap-pcf/concourse.yml -l ./concourse-vars.yml
