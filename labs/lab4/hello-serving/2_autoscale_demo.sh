#!/bin/zsh

clear

printf "------------\nStarting...\n"

printf "\nGet current pods...\n"
kubectl get pods

printf "\nList current revisions...\n"
kn revision list

printf "\nLet's specify the autoscale limits...\n"
kn service update hello-stls --scale 0..5

printf "\nLoad test...\n"
zsh ./load_test.sh

printf "\nDone!\n------------\n\n"
