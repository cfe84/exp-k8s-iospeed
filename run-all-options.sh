#! /bin/bash

ITERATIONS=10
FILE_COUNT=10
FILE_SIZE=1Mb
RESULT_FILE=
BASENAME=speedtest

usage() { echo "Usage: `basename "$0"` [--name/-n BASENAME] [--output/-o RESULT_FILE] [--iterations/-i ITERATIONS] [--file-count/-f FILE_COUNT] [--file-size/-s FILE_SIZE]"; exit 1; }

if [ -z "$STANDARD_STORAGE_ACCOUNT_KEY" ]; then
    echo "Looks like env file has not been sourced"
    usage
fi

while [[ $# -gt 0 ]]
do
    key="$1"
    shift

    case $key in
        -n|--name)
            BASENAME="$1"
            shift
        ;;
        -o|--output)
            RESULT_FILE="$1"
            shift
        ;;
        -i|--iterations)
            ITERATIONS="$1"
            shift
        ;;
        -f|--file-count)
            FILE_COUNT="$1"
            shift
        ;;
        -s|--file-size)
            FILE_SIZE="$1"
            shift
        ;;
        *)
            echo "Unknown parameter: $key"
            usage
        ;;
    esac
done

if [ -z "$RESULT_FILE" ]; then
    RESULT_FILE=$BASENAME.csv
fi

COMMON_PARAMETERS="--output $RESULT_FILE --testConfigFiles $FILE_COUNT --testConfigIterations $ITERATIONS --testConfigFilesize $FILE_SIZE"

# ACI
./run.sh --name "$BASENAME-aci" --virtualnodes true $COMMON_PARAMETERS

COMMON_PARAMETERS="$COMMON_PARAMETERS --hideHeader true"

# On agent
POOLS="d2sv3 d2v3 ds2v2 ds3v2"
for POOL in $POOLS; do
    ./run.sh --name "$BASENAME-agent-$POOL" --poolName "$POOL" $COMMON_PARAMETERS 
done

COMMON_PARAMETERS="$COMMON_PARAMETERS --poolName agentpool"

# Fileshare standard
./run.sh --name "$BASENAME-fileshare-standard" \
    --shareName $SHARE_NAME --accountName $STANDARDSTORAGE_STORAGE_ACCOUNT \
    --accountKey $STANDARD_STORAGE_ACCOUNT_KEY --testfile /storage/folder \
    --storageName standard $COMMON_PARAMETERS

# Fileshare premium
./run.sh --name "$BASENAME-fileshare-premium" \
    --shareName $SHARE_NAME --accountName $PREMIUMSTORAGE_STORAGE_ACCOUNT \
    --accountKey $PREMIUM_STORAGE_ACCOUNT_KEY --testfile /storage/folder \
    --storageName premium $COMMON_PARAMETERS

# Disk standard
./run.sh --name "$BASENAME-disk-standard" \
    --diskSku default \
    --testfile /storage/test $COMMON_PARAMETERS
    
# Disk premium
./run.sh --name "$BASENAME-disk-premium" \
    --diskSku managed-premium \
    --testfile /storage/test $COMMON_PARAMETERS