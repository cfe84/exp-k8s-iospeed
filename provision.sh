#!/bin/bash

PWD=`pwd`
usage() { echo "Usage: `basename "$0"` [--name $NAME] [--location $LOCATION]"; exit 1; }
random() { size=$1; echo -n `date +%s%N | sha256sum | base64 | head -c $size`;}
shorten() { size="$1"; input="$2"; echo "$input" | head -c "$size"; }
strip() { character="$1"; input="$2"; echo "$input" | sed "s/[$character]//g"; }
lower() { input="$1"; echo "$input" | sed -e 's/\(.*\)/\L\1/'; }
upper() { input="$1"; echo "$input" | sed -e 's/\(.*\)/\U\1/'; }
escape() { input="$1"; echo "$input" | sed -e 's/\//\\\//g'; }

RANDOMBASE="`random 5`"
RANDOMBASE16CHAR="`random 16`"
SUBSCRIPTIONID="`az account show --query id -o tsv`"
SUBSCRIPTION_RESOURCE_ID="/subscriptions/$SUBSCRIPTIONID"
NAME="`basename "$PWD"`"
LOCATION="centralus"

while [[ $# -gt 0 ]]
do
    key="$1"
    shift

    case $key in
        -n|--name)
            NAME="$1"
            shift
        ;;
        -l|--location)
            LOCATION="$1"
            shift
        ;;
        *)
            echo "Unknown parameter: $key"
            usage
        ;;
    esac
done


ENVFILE="env-$NAME.sh"
if [ ! -f $ENVFILE ]; then
    echo "#!/bin/bash

NAME='$NAME'
LOCATION=\"$LOCATION\"
RANDOMBASE=\"$RANDOMBASE\"
RANDOMBASE16CHAR=\"$RANDOMBASE16CHAR\"
STORAGEBASENAME=\"`echo -n $NAME | head -c 15`$RANDOMBASE\"
SUBSCRIPTIONID=\"$SUBSCRIPTIONID\"
SUBSCRIPTION_RESOURCE_ID=\"$SUBSCRIPTION_RESOURCE_ID\"
TENANTID=`az  account show --query tenantId -o tsv`

" > $ENVFILE
fi


source $ENVFILE




echo "This will provision the following resources: "
echo "ResourceGroup (default)"
echo "StorageAccount (standardStorage)"
echo "StorageAccount (premiumStorage)"
echo "Disk (standardDisk)"
echo "Disk (premiumDisk)"
echo "Snippet (Create share)"
echo "Snippet (Authorize AKS cluster)"

DEFAULT_RESOURCE_GROUP="$NAME"
DEFAULT_RESOURCE_GROUP_RESOURCE_ID="$SUBSCRIPTION_RESOURCE_ID/resourceGroups/$DEFAULT_RESOURCE_GROUP"
STANDARDSTORAGE_STORAGE_ACCOUNT="`echo "$STORAGEBASENAME" | sed -e 's/-//g' | sed -E 's/^(.*)$/\L\1/g' | head -c 20`sta"
STANDARDSTORAGE_STORAGE_ACCOUNT_RESOURCE_ID="$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Storage/storageAccounts/$STANDARDSTORAGE_STORAGE_ACCOUNT"
PREMIUMSTORAGE_STORAGE_ACCOUNT="`echo "$STORAGEBASENAME" | sed -e 's/-//g' | sed -E 's/^(.*)$/\L\1/g' | head -c 20`pre"
PREMIUMSTORAGE_STORAGE_ACCOUNT_RESOURCE_ID="$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Storage/storageAccounts/$PREMIUMSTORAGE_STORAGE_ACCOUNT"
STANDARDDISK_DISK="standardDisk-disk";
STANDARDDISK_DISK_RESOURCE_ID="$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Compute/disks/$STANDARDDISK_DISK"
PREMIUMDISK_DISK="premiumDisk-disk";
PREMIUMDISK_DISK_RESOURCE_ID="$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Compute/disks/$PREMIUMDISK_DISK"
SHARE_NAME=speedtest
echo "Creating resource group $DEFAULT_RESOURCE_GROUP"
az group create --name $DEFAULT_RESOURCE_GROUP --location $LOCATION --query "properties.provisioningState" -o tsv

echo "Creating storage account $STANDARDSTORAGE_STORAGE_ACCOUNT"
az storage account create --name $STANDARDSTORAGE_STORAGE_ACCOUNT --kind StorageV2 --sku Standard_LRS --location $LOCATION -g $DEFAULT_RESOURCE_GROUP --https-only true --query "provisioningState" -o tsv
STANDARDSTORAGE_STORAGE_ACCOUNT_CONNECTION_STRING=`az storage account show-connection-string -g $DEFAULT_RESOURCE_GROUP -n $STANDARDSTORAGE_STORAGE_ACCOUNT --query connectionString -o tsv`
echo "Creating container $STANDARDSTORAGE_STORAGE_ACCOUNT.speedtest"
az storage container create --name "speedtest" --account-name $STANDARDSTORAGE_STORAGE_ACCOUNT --query "created" -o tsv

echo "Creating storage account $PREMIUMSTORAGE_STORAGE_ACCOUNT"
az storage account create --name $PREMIUMSTORAGE_STORAGE_ACCOUNT --kind FileStorage --sku Premium_LRS --location $LOCATION -g $DEFAULT_RESOURCE_GROUP --https-only true --query "provisioningState" -o tsv
PREMIUMSTORAGE_STORAGE_ACCOUNT_CONNECTION_STRING=`az storage account show-connection-string -g $DEFAULT_RESOURCE_GROUP -n $PREMIUMSTORAGE_STORAGE_ACCOUNT --query connectionString -o tsv`

echo "Creating disk $STANDARDDISK_DISK"
az disk create --resource-group $DEFAULT_RESOURCE_GROUP --name $STANDARDDISK_DISK --location $LOCATION --sku Standard_LRS --size-gb 20 --os-type Windows --query "provisioningState" -o tsv

echo "Creating disk $PREMIUMDISK_DISK"
az disk create --resource-group $DEFAULT_RESOURCE_GROUP --name $PREMIUMDISK_DISK --location $LOCATION --sku Premium_LRS --size-gb 20 --os-type Windows --query "provisioningState" -o tsv

echo "Creating share"
az storage share create \
  --account-name $STANDARDSTORAGE_STORAGE_ACCOUNT \
  --name $SHARE_NAME -o tsv --query created
az storage share create \
  --account-name $PREMIUMSTORAGE_STORAGE_ACCOUNT \
  --name $SHARE_NAME -o tsv --query created


echo "Authorizing AKS cluster to access the disk:"
read -p "AKS cluster name >" AKS_CLUSTER_NAME
read -p "AKS resource group >" AKS_RESOURCE_GROUP
CLIENT_ID=$(az aks show --name $AKS_CLUSTER_NAME -g $AKS_RESOURCE_GROUP --query servicePrincipalProfile.clientId -o tsv)
az role assignment create --role Contributor --resource-group $DEFAULT_RESOURCE_GROUP --assignee $CLIENT_ID --query roleDefinitionName -o tsv


echo "

DEFAULT_RESOURCE_GROUP=\"$NAME\"
DEFAULT_RESOURCE_GROUP_RESOURCE_ID=\"$SUBSCRIPTION_RESOURCE_ID/resourceGroups/$DEFAULT_RESOURCE_GROUP\"
STANDARDSTORAGE_STORAGE_ACCOUNT=\"\`echo \"$STORAGEBASENAME\" | sed -e 's/-//g' | sed -E 's/^(.*)$/\L\1/g' | head -c 20\`sta\"
STANDARDSTORAGE_STORAGE_ACCOUNT_RESOURCE_ID=\"$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Storage/storageAccounts/$STANDARDSTORAGE_STORAGE_ACCOUNT\"
PREMIUMSTORAGE_STORAGE_ACCOUNT=\"\`echo \"$STORAGEBASENAME\" | sed -e 's/-//g' | sed -E 's/^(.*)$/\L\1/g' | head -c 20\`pre\"
PREMIUMSTORAGE_STORAGE_ACCOUNT_RESOURCE_ID=\"$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Storage/storageAccounts/$PREMIUMSTORAGE_STORAGE_ACCOUNT\"
STANDARDDISK_DISK=\"standardDisk-disk\";
STANDARDDISK_DISK_RESOURCE_ID=\"$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Compute/disks/$STANDARDDISK_DISK\"
PREMIUMDISK_DISK=\"premiumDisk-disk\";
PREMIUMDISK_DISK_RESOURCE_ID=\"$DEFAULT_RESOURCE_GROUP_RESOURCE_ID/providers/Microsoft.Compute/disks/$PREMIUMDISK_DISK\"
SHARE_NAME=speedtest

STANDARDSTORAGE_STORAGE_ACCOUNT_CONNECTION_STRING=\"\`az storage account show-connection-string -g $DEFAULT_RESOURCE_GROUP -n $STANDARDSTORAGE_STORAGE_ACCOUNT --query connectionString -o tsv\`\"
PREMIUMSTORAGE_STORAGE_ACCOUNT_CONNECTION_STRING=\"\`az storage account show-connection-string -g $DEFAULT_RESOURCE_GROUP -n $PREMIUMSTORAGE_STORAGE_ACCOUNT --query connectionString -o tsv\`\"
STANDARD_STORAGE_ACCOUNT_KEY=\`az storage account keys list \
  --account-name $STANDARDSTORAGE_STORAGE_ACCOUNT \
  --query [0].value \
  -o tsv\`
PREMIUM_STORAGE_ACCOUNT_KEY=\`az storage account keys list \
  --account-name $PREMIUMSTORAGE_STORAGE_ACCOUNT \
  --query [0].value \
  -o tsv\`

" >> $ENVFILE

echo "Generating cleanup script"
echo "#!/bin/bash
echo 'Removing resource group $DEFAULT_RESOURCE_GROUP'
az group delete --name $DEFAULT_RESOURCE_GROUP --yes
rm $ENVFILE
" > cleanup-$NAME.sh
chmod +x cleanup-$NAME.sh
        
echo "    Resource group name: $DEFAULT_RESOURCE_GROUP"
echo "  Storage account (sta): $STANDARDSTORAGE_STORAGE_ACCOUNT"
echo "      Storage key (sta): $STANDARDSTORAGE_STORAGE_ACCOUNT_CONNECTION_STRING"
echo "  Storage account (pre): $PREMIUMSTORAGE_STORAGE_ACCOUNT"
echo "      Storage key (pre): $PREMIUMSTORAGE_STORAGE_ACCOUNT_CONNECTION_STRING"
echo "         Disk (standardDisk): $STANDARDDISK_DISK"
echo "         Disk (premiumDisk): $PREMIUMDISK_DISK"
