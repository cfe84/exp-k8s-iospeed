# Run a batch:

```sh
POOLS="d2sv3 d2v3 ds2v2 ds3v2"

for POOL in $POOLS; do
    helm template . --set name=speedtest-$POOL --set poolName=$POOL | kubectl apply -f -
done

PODS=$(kubectl get pods -o json | jq ".items[].metadata.name" -r)
for POD in $PODS; do
    echo
    echo "# On host ($POD)"
    echo
    kubectl logs $POD
done
```

# Run on a given pool:

```sh
helm template . --set name=iops-d2sv3-2 --set poolName=agentpool | kubectl apply -f -
```

# Run on ACI:

```sh
helm template . --set name=speedtest-aci --set virtualnodes=true | kubectl apply -f -
```

# Run with fileshare (source environment file first)

- standard: 

```sh
helm template . --set name=speedtest-fileshare-standard --set shareName=$SHARE_NAME --set accountName=$STANDARDSTORAGE_STORAGE_ACCOUNT --set accountKey=$STANDARD_STORAGE_ACCOUNT_KEY --set testfile=/storage/folder --set storageName=standard --set poolName=agentpool | kubectl apply -f -
```

- premium 

```sh
helm template . --set name=speedtest-fileshare-premium --set shareName=$SHARE_NAME --set accountName=$PREMIUMSTORAGE_STORAGE_ACCOUNT --set accountKey=$PREMIUM_STORAGE_ACCOUNT_KEY --set testfile=/storage/test --set storageName=premium  --set poolName=agentpool | kubectl apply -f -
```



# Run with disk (source environment file first)

- Standard

```sh
helm template . --set name=speedtest-disk-standard --set diskId=$STANDARDDISK_DISK_RESOURCE_ID --set diskName=$STANDARDDISK_DISK --set testfile=/storage/test --set poolName=agentpool | kubectl apply -f -
```

- Premium

```sh
helm template . --set name=speedtest-disk-premium-2 --set diskId=$PREMIUMDISK_DISK_RESOURCE_ID --set diskName=$PREMIUMDISK_DISK --set testfile=/storage/test --set poolName=agentpool | kubectl apply -f -
```