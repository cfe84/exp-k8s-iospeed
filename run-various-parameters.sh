#!/bin/bash

NAME=speedtest-full

bold=$(tput bold)
normal=$(tput sgr0)

title() {
    RUN_NAME=$1
    echo -e "${bold}${RUN_NAME}${normal}"
}

title "Larger files"
source run-all-options.sh --name $NAME -i 1 -f 5 -s 100Mb

title "Large files"
source run-all-options.sh --name $NAME -i 2 -f 5 -s 10Mb

title "Very small files"
source run-all-options.sh --name $NAME -i 10 -f 1000 -s 10kb

title "Medium files"
source run-all-options.sh --name $NAME -i 10 -f 10 -s 1Mb

title "Small files"
source run-all-options.sh --name $NAME -i 10 -f 100 -s 100kb
