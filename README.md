# Azure and Github Actions

## Storage Acocunt

### Create needed local env variables

~~~bash
prefix=cptdazgitaction
location=germanywestcentral
# create resource group
az group create -n $prefix -l $location
~~~

### Create Service Principal

~~~bash
# Retrieve the subscription id
subid=$(az account show --query id -o tsv)
# Create Service Principal which will be used in combination with Github Actions
sppassword=$(az ad sp create-for-rbac --name $prefix --role Owner --scopes /subscriptions/$subid/resourceGroups/$prefix --query password -o tsv)
# Verify the Service Principal
az ad sp list --display-name $prefix
~~~

### Setup github repo

~~~ bash
gh repo create $prefix --public
git init
git checkout -b main
git remote add origin https://github.com/cpinotossi/$prefix.git
git status
# Create Environment Production in the repo
gh api repos/cpinotossi/$prefix/environments/production -X PUT
~~~

## Github Actions

Setup azure credentials for github actions based on [Use GitHub Actions to connect to Azure](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure) without secrets.

~~~bash
appid=$(az ad sp list --display-name $prefix --query [0].appId -o tsv)
objectid=$(az ad sp list --display-name $prefix --query [0].id -o tsv)
# allow github to create tokens via inpersonation of the service principal
# IMPORTANT: please change the credential.json file to your needs
az ad app federated-credential create --id $appid --parameters ./github.action/credential.json
# verify federation setup
az ad app federated-credential list --id $appid
~~~

We are going to provide some secretes and variables via the github build in secrets and variables feature.

~~~bash
# create github secret via gh cli for repo cptdazlz
gh secret set AZURE_CLIENT_ID -b $appid -e production
tid=$(az account show --query tenantId -o tsv)
gh secret set AZURE_TENANT_ID -b $tid -e production
gh secret set AZURE_SUBSCRIPTION_ID -b $subid -e production
gh secret set AZURE_OBJECT_ID -b $objectid -e production
gh secret list --env production
# create variables
gh variable set STORAGE_NAME -b $prefix --env production
gh variable set LOCATION -b "germanywestcentral" --env production
gh variable set RGROUP_NAME -b $prefix --env production
gh variable set RG_NAME -b "cptdazgitaction" --env production
gh variable list --env production
~~~

### Trigger github actions

~~~bash
git add .
git commit -m"init"
git push origin main

# List all runs for a repository
gh run list --repo cpinotossi/$prefix
# View the details of the last run
gh run view $(gh run list --repo cpinotossi/$prefix --json databaseId --jq '.[0].databaseId') --repo cpinotossi/$prefix --log
~~~


