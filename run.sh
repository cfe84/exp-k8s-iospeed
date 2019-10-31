#! /bin/bash

NAMESPACE=io-speed-test

function jobIsRunning() {
    local JOB_NAME="$1"
    COMPLETION_TIME=$(kubectl -n $NAMESPACE get job "$JOB_NAME" -o json | \
        jq ".status.completionTime")
    if [ "$COMPLETION_TIME" = "null" ]; then
        echo "true"
    else
        echo "false"
    fi
}

COMMAND=""
JOB_NAME=""
OUTPUT_FILE="./test-results.csv"

while [[ $# -gt 0 ]]
do
    key=$(echo "$1" | sed "s/^--//")
    shift
    value="$1"
    shift
    if [ "$key" = "name" ]; then
        JOB_NAME="$value"
    fi
    if [ "$key" = "output" ]; then
        OUTPUT_FILE=$value
    else
        COMMAND="$COMMAND --set $key=$value"
    fi
done

COMMAND="helm template . $COMMAND"

echo -en "🚀  Executing job \e[3m$JOB_NAME\e[0m"
# echo -e "\n (Command is \e[3m$COMMAND\e[0m)"
$COMMAND | kubectl apply -f - > /dev/null

echo -en "\r⌚  Waiting for job \e[3m$JOB_NAME\e[0m"

while [ $(jobIsRunning "$JOB_NAME") = "true" ]
do
    echo -n "."
    sleep 1
done

echo -ne "\r🔎  Retrieving pod name of job \e[3m$JOB_NAME\e[0m                                         \r"

POD_NAME="$(kubectl -n $NAMESPACE get pods -o json | jq ".items[] | select(.metadata.labels[\"job-name\"] == \"$JOB_NAME\") | .metadata.name" -r)"
echo -ne "\r📃  Grabbing logs (\e[3mpod $POD_NAME\e[0m)        "
kubectl -n $NAMESPACE logs $POD_NAME >> "$OUTPUT_FILE"
echo -ne "\r🧹  Job \e[3m$JOB_NAME\e[0m done, cleaning up                          "
$COMMAND | kubectl delete -f - > /dev/null
echo -ne "\r✔  Job \e[3m$JOB_NAME\e[0m complete                                   "
echo