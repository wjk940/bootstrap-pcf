#!/usr/bin/env bash
set -e
set -x

#
# before we can create a bosh environment, there is some initialization, see:
# http://bosh.io/docs/azure-resources.html
# http://docs.pivotal.io/pivotalcf/1-10/refarch/azure/azure_ref_arch.html
# http://docs.pivotal.io/pivotalcf/1-10/customizing/azure-prepare-env.html
#
# there are some interactive steps, to set up credentials for non-interactive API client
#	az login
#	az account list --output json
#

export YOUR_NAME=
export CLOUDNAME=AzureCloud
export SUBSCRIPTION_ID=
export TENANT_ID=
export APP_DISPLAY_NAME=""
export APP_HOMEPAGE=http://${YOUR_NAME}BOSHAzureCPI
export APP_IDENTIFIER_URI=http://${YOUR_NAME}BOSHAzureCPI
export CLIENT_ID=http://${YOUR_NAME}BOSHAzureCID
export CLIENT_SECRET=
export RESOURCE_GROUP_NAME=${YOUR_NAME}Bootstrap-rg
export VNET_NAME=${YOUR_NAME}Bootstrap-vnet
export SUBNET_NAME=bootstrap
export JUMPBOX_PUBLIC_IP_NAME=jumpbox-pubip
export CONCOURSE_PUBLIC_IP_NAME=concourse-pubip
export BOSH_NSG=bosh-nsg
export NETWORK_SECURITY_GROUP=${YOUR_NAME}Bootstrap-nsg
export AZURE_STORAGE_ACCOUNT=$(echo ${YOUR_NAME}storacct | tr '[:upper:]' '[:lower:]')
export ADMIN_USER=
export SSH_PUBLIC_KEY=

az configure --defaults location=westus
az account set --subscription $SUBSCRIPTION_ID

az provider register -n Microsoft.Network
az provider register -n Microsoft.Storage
az provider register -n Microsoft.Compute

az ad app create \
	--display-name "$APP_DISPLAY_NAME" \
	--homepage $APP_HOMEPAGE \
	--identifier-uris $APP_IDENTIFIER_URI \
	--password $CLIENT_SECRET

#az ad sp create --id $APP_IDENTIFIER_URI
az ad sp create-for-rbac --name $CLIENT_ID --password $CLIENT_SECRET --role "Contributor"
#az role assignment create --assignee $APP_IDENTIFIER_URI --role "Contributor"

az group create --name $RESOURCE_GROUP_NAME

az network vnet create --name $VNET_NAME --resource-group $RESOURCE_GROUP_NAME

az network nsg create --name $BOSH_NSG --resource-group $RESOURCE_GROUP_NAME

az network nsg rule create \
	--name 'ssh' \
	--nsg-name bosh-nsg \
	--priority 200 \
	--resource-group $RESOURCE_GROUP_NAME \
	--access Allow \
	--destination-address-prefix '*' \
	--destination-port-range 22 \
	--direction Inbound \
	--protocol Tcp \
	--source-address-prefix Internet \
	--source-port-range '*'

az network nsg rule create \
	--name 'bosh-agent' \
	--nsg-name bosh-nsg \
	--priority 201 \
	--resource-group $RESOURCE_GROUP_NAME \
	--access Allow \
	--destination-address-prefix '*' \
	--destination-port-range 6868 \
	--direction Inbound \
	--protocol Tcp \
	--source-address-prefix Internet \
	--source-port-range '*'

az network nsg rule create \
	--name 'bosh-director' \
	--nsg-name bosh-nsg \
	--priority 202 \
	--resource-group $RESOURCE_GROUP_NAME \
	--access Allow \
	--destination-address-prefix '*' \
	--destination-port-range 25555 \
	--direction Inbound \
	--protocol Tcp \
	--source-address-prefix Internet \
	--source-port-range '*'

az network nsg rule create \
	--name 'dns' \
	--nsg-name bosh-nsg \
	--priority 203 \
	--resource-group $RESOURCE_GROUP_NAME \
	--access Allow \
	--destination-address-prefix '*' \
	--destination-port-range 53 \
	--direction Inbound \
	--protocol '*' \
	--source-address-prefix Internet \
	--source-port-range '*'

az network nsg create --name $NETWORK_SECURITY_GROUP --resource-group $RESOURCE_GROUP_NAME

az network nsg rule create \
	--name 'web-https' \
	--nsg-name $NETWORK_SECURITY_GROUP \
	--priority 201 \
	--resource-group $RESOURCE_GROUP_NAME \
	--access Allow \
	--destination-address-prefix '*' \
	--destination-port-range 443 \
	--direction Inbound \
	--protocol Tcp \
	--source-address-prefix Internet \
	--source-port-range '*'

az network nsg rule create \
	--name 'concourse-https' \
	--nsg-name $NETWORK_SECURITY_GROUP \
	--priority 202 \
	--resource-group $RESOURCE_GROUP_NAME \
	--access Allow \
	--destination-address-prefix '*' \
	--destination-port-range 4443 \
	--direction Inbound \
	--protocol Tcp \
	--source-address-prefix Internet \
	--source-port-range '*'

az network vnet subnet create \
	--address-prefix 10.0.0.0/24 --name $SUBNET_NAME --resource-group $RESOURCE_GROUP_NAME --vnet-name $VNET_NAME

az network public-ip create --name $JUMPBOX_PUBLIC_IP_NAME --resource-group $RESOURCE_GROUP_NAME --allocation-method Static

az network public-ip create --name $CONCOURSE_PUBLIC_IP_NAME --resource-group $RESOURCE_GROUP_NAME --allocation-method Static


az storage account create --name $AZURE_STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP_NAME --sku Standard_LRS

# 
export AZURE_STORAGE_KEY=$(az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP_NAME | jq -r .[0].value)
az storage container create --name bosh
az storage container create --name stemcell
az storage table create --name stemcells

az login --service-principal --password $CLIENT_SECRET --tenant $TENANT_ID --username $CLIENT_ID

#
# create jumpbox VM
az vm create \
	--name jumpbox \
	--resource-group $RESOURCE_GROUP_NAME \
	--admin-username $ADMIN_USER \
	--authentication-type ssh \
	--image UbuntuLTS \
	--nsg bosh-nsg \
	--nsg-rule SSH \
	--private-ip-address 10.0.0.4 \
	--public-ip-address $JUMPBOX_PUBLIC_IP_NAME \
	--size Standard_DS1_v2 \
	--ssh-key-value $SSH_PUBLIC_KEY \
	--subnet $SUBNET_NAME \
	--vnet-name $VNET_NAME
