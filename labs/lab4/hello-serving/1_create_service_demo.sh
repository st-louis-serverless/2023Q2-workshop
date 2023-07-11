#!/bin/zsh

clear

printf "------------\nStarting...\n"
printf "\nCreate Knative service (forcing in case it exists)...\n"
kn service create hello-stls --filename hello-stls.yaml --force

printf "\nGet pods...\n"
kubectl get pods

printf "\nList services...\n"
kn service list

printf "\nList revisions...\n"
kn revision list

printf "\nDescribe service...\n"
kn service describe hello-stls

printf "\nDescribe route...\n"
kn route describe hello-stls

printf "\nDone!\n------------\n\n"
