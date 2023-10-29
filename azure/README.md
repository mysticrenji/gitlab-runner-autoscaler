Please refer the medium article [here](https://faun.pub/baking-images-in-azure-using-azure-pipelines-93accd20b230) for complete walkthrough.

## Configuration
### 1. Install azcli
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
### 2. Install Terraform & Packer
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common gpg
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y packer terraform
```
### 3. Create Azure Service Principal
```
az login --use-device-code

// Copy the Output after SP Creation and save it
az ad sp create-for-rbac
--role="Contributor"
--scopes="/subscriptions/<$subscriptionid>"
```

### 4. Create Terraform Blob Storage to store state file
There is a script in the repo named backend-storage.sh to create the azure storage account and container. Please dont forget to change the values in the script, according to your needs.
```
backend-storage.sh <RESOURCE_GROUP_NAME> <STORAGE_ACCOUNT_NAME> <CONTAINER_NAME> <LOCATION>
```

### 5. Exporting environment variables of SP for ARM authentication
Export the SP credentials that you created in the previous step (3) into shell, so that Terraform automatically reads the Environment variables and use it authenticate with Azure Resource Manager (ARM)
```
export ARM_CLIENT_ID=
export ARM_SUBSCRIPTION_ID=
export ARM_TENANT_ID=
export ARM_CLIENT_SECRET=
export ARM_ACCESS_KEY=
```
### 6. Terraform execute
```
terraform init
terraform apply -var-file=auto.tfvars
```

## Packer

### 1. Format and validate Packer
```
packer init .
packer fmt -recursive .
packer validate -var-file="auto.pkrvars.hcl"
```
### 2. Build Packer
```
packer build -force -var-file="auto.pkrvars.hcl" \
             -var "azure_client_id=$ARM_CLIENT_ID" \
             -var "azure_client_secret=$ARM_CLIENT_SECRET" \
             -var "azure_subscription_id=$ARM_SUBSCRIPTION_ID" \
             -var "azure_tenant_id=$ARM_TENANT_ID" \
             .
```

## Tips
1. List out the availiable SKUs on the region
```
az vm list-skus --location westeutope --size Standard_D --all --output table