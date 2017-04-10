#Bootstrap OCB
Currently, automating Pivotal Cloud Foundry (PCF) uses OCB (OpsManager, Concourse, BOSH). In the future, there will be [BOSH-Native PCF](http://bosh-native-pcf-docs.pezapp.io/pcfbosh/index.html).

Before running pipelines for OCB, one must bootstrap an environment. At a minimum, you need a BOSH Director, so you can deploy and maintain Concourse.

Following are steps to go from an IaaS to deployed PCF plus a set of tiles to provide "AppTone". As a final layer of automation, a set of pipelines to maintain PCF and tiles are added.
##Jumpbox
1. Deploy a linux VM
2. Add support for Docker to this VM
3. We use [cfjump](https://github.com/RamXX/cfjump), which is installed by `docker pull ramxx/cfjump:latest`

A helper shell, `cfj`, is installed to simplify using the jumpbox for multiple environments.
##Create BOSH Environment
Decide on a name for the PCF instance you are bootstraping (e.g., bootstrap). After logging into you jumpbox VM, `cfj bootstrap`.
Next, clone these repos:

* https://github.com/wjk940/bosh-deployment
* https://github.com/wjk940/bootstrap-pcf

The repos have var file templates. Copy and fill out these templates for your own deployment(s):

* ./bosh-deployment/vsphere/params.yml
* Note, ./bosh-deployment/{aws,azure,gcp}/params.yml are coming soone from some volunteers
* ./bootstrap-pcf/concourse-vars.yml

There are a couple helper shells, which you can adjust for the location and name of your vars files:

* ./bootstrap-pcf/mkboshadmin.sh
* ./bootstrap-pcf/mkconcourse.sh

