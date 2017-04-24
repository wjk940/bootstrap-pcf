#!/usr/bin/env bash
set -e
set -x

#
# before we can create a bosh environment, there is some initialization, see:
# http://bosh.io/docs/init-aws.html
# http://docs.pivotal.io/pivotalcf/1-10/refarch/aws/aws_ref_arch.html
# http://docs.pivotal.io/pivotalcf/1-10/customizing/cloudform-template.html
#
# there are some interactive steps, to set up credentials for non-interactive API client
#	az login
#	az account list --output json
#
