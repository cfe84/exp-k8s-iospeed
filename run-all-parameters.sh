#!/bin/bash

NAME=speedtest

bold=$(tput bold)
normal=$(tput sgr0)

title() {
    RUN_NAME=$1
    echo -e "${bold}${RUN_NAME}${normal}"
}

title "Medium files"
source run-all.sh --name $NAME -i 10 -f 10 -s 1Mb

title "Small files"
source run-all.sh --name $NAME -i 10 -f 100 -s 100kb

title "Very small files"
source run-all.sh --name $NAME -i 10 -f 1000 -s 10kb

title "Large files"
source run-all.sh --name $NAME -i 10 -f 10 -s 10Mb

title "Larger files"
source run-all.sh --name $NAME -i 10 -f 10 -s 1Mb
