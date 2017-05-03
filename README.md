# Bootstrap OCB

Currently, automating Pivotal Cloud Foundry (PCF) uses OCB (OpsManager, Concourse, BOSH). In the future, there will be [BOSH-Native PCF](http://bosh-native-pcf-docs.pezapp.io/pcfbosh/index.html).

Before running pipelines for OCB, one must bootstrap an environment. At a minimum, you need a BOSH Director, so you can deploy and maintain Concourse.

Following are steps to go from an IaaS to deployed PCF plus a set of tiles to provide "AppTone". As a final layer of automation, a set of pipelines to maintain PCF and tiles are added.

## Jumpbox

1. Deploy a linux VM
2. Add support for Docker to this VM
3. We use [cfjump](https://github.com/RamXX/cfjump), which is installed by `docker pull ramxx/cfjump:latest`

A helper shell, `cfj`, should be installed on your PATH (e.g., ~/bin/cfj). `cfj` simplifies using the jumpbox for multiple environments. (Show raw on github, copy, and paste into vim on your jumpbox is one way to get this helper installed.)

## Create BOSH Environment

Decide on a name for the PCF instance you are bootstraping (e.g., bootstrap). After logging into you jumpbox VM, `cfj bootstrap`.
Next, clone these repos:

* https://github.com/wjk940/bosh-deployment
* https://github.com/wjk940/bootstrap-pcf

The repos have var file templates. Copy and fill out these templates for your own deployment(s):

* ./bosh-deployment/{aws,azure,gcp,vsphere}/params.yml
* ./bootstrap-pcf/concourse-param.yml

There are a couple helper shells, which you can adjust for the location and name of your vars files:

* ./bootstrap-pcf/{aws,azure,gcp,vsphere}/ may contain an init-*.sh to ease creating all the resources needed before bootstrapping
* ./bootstrap-pcf/{aws,azure,gcp,vsphere}/mkboshadmin.sh
* ./bootstrap-pcf/{aws,azure,gcp,vsphere}/mkconcourse.sh provide your own certificate/key
* ./bootstrap-pcf/{aws,azure,gcp,vsphere}/mkconcourseca.sh BOSH created certificate/key

Using your modified helper shells, run `mkboshadmin.sh`. Once you have successfully deployed director, run `mkconcourse.sh` or `mkconcourseca.sh`.

## Deploy OpsManager and Elastic Runtime

Now, we get on with installing OpsManager and Elastic Runtime. The pcf-pipelines project is creating day 1 (initial install) and day 2 (ongoing upgrade) pipelines. PCF-Pipelines are available on [PivNet](https://network.pivotal.io/products/pcf-automation). For vSphere, I recommend using a [fork of concourse-vsphere](https://github.com/wjk940/concourse-vsphere), which has modifications to support the portfolio of tiles you will install after OpsManager and Elastic Runtime.

## Deploy Tiles for "AppTone"
Pipelines for the initial deploy of a set of tiles, which I refer to as AppTone, are available in a [fork of pcf-pipelines](https://github.com/wjk940/pcf-pipelines). The order is somewhat important, as some tiles depend on others. A suggested order is:

1. Isolation Segment
2. Redis
3. APM (aka PCF Metrics)
4. RabbitMQ
5. MySQL
6. Spring Cloud Services

## Day 2
Finally, create a params.yml for each of the upgrade pipelines. There should be upgrades for:

* OpsManager
* Elastic Runtime
* Buildpacks
* and one for each tile deployed in the preceding section