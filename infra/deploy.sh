#!/bin/bash
set -e

# This script automates the process of setting up a resource group, a key vault,
# and secrets within the key vault in Azure. It also assigns the 'Key Vault Secrets User'
# role to a specified service principal.

# Parameters
resourceGroupName="DEMO-rg-name"  # The name of the resource group to create or use
defaultLocaton="westus3"  # The default location for the resource group
servicePrincipalName="service-principal-name"  # The name of the *existing* service principal
keyVaultName="key-vault-name"  # The name of the key vault

# Log in first: az login --use-device-code

# Ensure logged in
az account show -o none

# Create a resource group if it doesn't already exist
if [ $(az group exists --name $resourceGroupName) = false ]; then
    echo "Creating resource group $resourceGroupName in location $defaultLocaton"
    az group create --name $resourceGroupName --location $defaultLocaton
else
    echo "Resource group $resourceGroupName already exists"
fi

# Get resource group location
location=$(az group show --name $resourceGroupName --query location --output tsv)

# Get service principal object ID
servicePrincipalObjectId=$(az ad sp list --display-name "$servicePrincipalName" --query "[0].id" -o tsv)

# Quit if service principal doesn't exist
if [ -z $servicePrincipalObjectId ]; then
    echo "Service principal $servicePrincipalName not found"
    exit 1
fi

# Create a key vault if it doesn't already exist
if [ $(az keyvault list --query "[?name=='$keyVaultName'].name" | jq 'length') != "1" ]; then
    echo "Creating key vault $keyVaultName in resource group $resourceGroupName"
    az keyvault create --name $keyVaultName \
      --resource-group $resourceGroupName \
      --location $location \
      --public-network-access enabled \
      --enable-rbac-authorization true \
      --retention-days 7
else
    echo "Key vault $keyVaultName already exists"
fi

# Get Key Vault ID
keyVaultId=$(az keyvault show --name $keyVaultName --query id --output tsv)
echo $keyVaultId

# Assign the Key Vault Secrets User role to the service principal using RBAC
az role assignment create --assignee $servicePrincipalObjectId --role "Key Vault Secrets User" --scope $keyVaultId

# Create secret1 with a value of value1
az keyvault secret set --vault-name $keyVaultName --name secret1 --value value1

# Create secret2 with a value of value2
az keyvault secret set --vault-name $keyVaultName --name secret2 --value value2

echo "Done."
