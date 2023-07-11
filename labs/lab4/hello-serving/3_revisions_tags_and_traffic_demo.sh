#!/bin/zsh

clear

# Any time we update the service, we get a new revision
# We could it all through a YAML config file, then use kubectl apply -f <filename>
# However, the Knative CLI make doing so very easy. We like easy.

# What can we do in an kn service update?
#   - apply new environment vars; e.g.: kn service update my-svc --env FFLAG_101=true
#   - make a revision using an updated image; e.g: kn service update my-svc --image some-repo/my-svc:build123
#   - make a revision from the latest; e.g: kn service update my-svc --revision-name ''

printf "------------\nStarting...\n"
printf "\nList current revisions...\n"
kn revision list

kn service update hello-stls --env TARGET="Feature Flag 1: True" --revision-name ff1t
kn service update hello-stls --env TARGET="Feature Flag 1: False" --revision-name ff1f
kn service update hello-stls --tag hello-stls-ff1t=ff1t \
                             --tag hello-stls-ff1f=ff1f \
                             --traffic ff1t=50,ff1f=50

printf "\nList revisions after update...\n"
kn revision list

printf "\nDescribe the route for the service...\n"
kn route describe hello-stls

printf "\nCurl each of the tag URLs...\n"
curl http://ff1t-hello-stls.default.127.0.0.1.sslip.io
curl http://ff1f-hello-stls.default.127.0.0.1.sslip.io

printf "\nLoad test...\n"
zsh ./load_test.sh

printf "\nDone!\n------------\n\n"

# Deleting revisions is a bit of a process:
# To delete a revision: untag it, point all traffic to a remaining revision, untag it, then delete it
# kn service update --traffic hello-stls-ff101f=100
# kn service update hello-stls --untag ff101t
# kn revision delete hello-stls-ff101t
# To remove all unreferenced revisions:
#   - per-service: kn revision delete --prune svc-name
#   - all services in a namespace: kn revision delete --prune-all
