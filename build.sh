#!/bin/bash

if [ -z "${SUBSCRIPTION_ID}" ]
    then echo "Please set the environment variable 'SUBSCRIPTION_ID' to continue."; exit
fi
subscriptionId=$SUBSCRIPTION_ID

if [ -z "${AZURE_CLIENT_ID}" ]
    then echo "Please set the environment variable 'AZURE_CLIENT_ID' to continue."; exit
fi
azureClientId=$AZURE_CLIENT_ID

if [ -z "${AZURE_SECRET_ID}" ]
    then echo "Please set the environment variable 'AZURE_SECRET_ID' to continue."; exit
fi
azureSecretId=$AZURE_SECRET_ID

if [ -z "${AZURE_TENANT_ID}" ]
    then echo "Please set the environment variable 'AZURE_TENANT_ID' to continue."; exit
fi
azureTenantId=$AZURE_TENANT_ID

if [ -z "${COST_CENTER_TAG}" ]
    then echo "Please set the environment variable 'COST_CENTER_TAG' to continue."; exit
fi
costCenterTag=$COST_CENTER_TAG

if [ -z "${SERVICE_TAG}" ]
    then echo "Please set the environment variable 'SERVICE_TAG' to continue."; exit
fi
serviceTag=$SERVICE_TAG

if [ -z "${CREATED_BY_TAG}" ]
    then echo "Please set the environment variable 'CREATED_BY_TAG' to continue."; exit
fi
createdByTag=$CREATED_BY_TAG

if [ -z "${RESOURCE_LOCATION}" ]
    then echo "Please set the environment variable 'RESOURCE_LOCATION' to continue."; exit
fi
resourceLocation=$RESOURCE_LOCATION

if [ -z "${RESOURCE_GROUP_NAME}" ]
    then echo "Please set the environment variable 'RESOURCE_GROUP_NAME' to continue."; exit
fi
resourceGroupName=$RESOURCE_GROUP_NAME

if [ -z "${APPSERVICE_PLAN_NAME}" ]
    then echo "Please set the environment variable 'APPSERVICE_PLAN_NAME' to continue."; exit
fi
appservicePlanName=$APPSERVICE_PLAN_NAME

if [ -z "${WEB_APP_NAME}" ]
    then echo "Please set the environment variable 'WEB_APP_NAME' to continue."; exit
fi
webappName=$WEB_APP_NAME

if [ -z "${GITHUB_REPO_URL}" ]
    then echo "Please set the environment variable 'GITHUB_REPO_URL' to continue."; exit
fi
githubURL=$GITHUB_REPO_URL

if [ -z "${GITHUB_TOKEN}" ]
    then echo "Please set the environment variable 'GITHUB_TOKEN' to continue."; exit
fi
githubToken=$GITHUB_TOKEN

# login to Azure with user credentials
# az login
az login --service-principal --username $azureClientId --password $azureSecretId --tenant $azureTenantId

# make sure we use the correct subscription
az account set --subscription $subscriptionId

# create resource group
echo "Creating resource group $resourceGroupName."
az group create --location $resourceLocation --name $resourceGroupName --tags "costCenter=$costCenterTag" "service=$serviceTag" "createdBy=$createdByTag"

# create appservice plan
az appservice plan create --name $appservicePlanName --resource-group $resourceGroupName --sku B1 --location $resourceLocation --tags "costCenter=$costCenterTag" "service=$serviceTag" "createdBy=$createdByTag"

# create webapp php
az webapp create --subscription $subscriptionId --resource-group $resourceGroupName --name $webappName --plan $appservicePlanName --runtime "php|7.3" --tags "costCenter=$costCenterTag" "service=$serviceTag" "createdBy=$createdByTag"

# deploy code method
az webapp deployment source config --name $webappName --resource-group $resourceGroupName --repo-url $githubURL --branch master --git-token $githubToken
