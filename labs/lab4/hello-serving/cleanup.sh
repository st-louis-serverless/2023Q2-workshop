#!/bin/zsh

clear

printf "------------\nStarting...\n"

printf "\nDelete artifacts...\n"
kn service delete hello-stls

printf "\nConfirm services present...\n"
kn service list

printf "\nDone!\n------------\n\n"
