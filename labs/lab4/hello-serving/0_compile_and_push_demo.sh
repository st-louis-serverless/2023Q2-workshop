#!/bin/zsh

clear

printf "------------\nStarting...\n"
printf "\nCompile typescript...\n"
npm run build

printf "\nBuild Docker image...\n"
docker build . -t hello-stls

printf "\nTag it...\n"
docker tag hello-stls:latest stlserverless/hello-stls:latest

# You need to be logged into the account for this.
printf "\nPush it...\n"
#docker push stlserverless/hello-stls:latest

printf "\nVerify it...\n"
docker images stlserverless/hello-stls

printf "\nDone!\n------------\n\n"
