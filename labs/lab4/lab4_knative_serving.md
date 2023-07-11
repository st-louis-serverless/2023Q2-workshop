# Lab 4 - Knative Serving

In this lab we will create a Knative Service and see the following in action:

- Review the code
- Compiling and pushing an image to our local registry (no Knative here)
- Create a Knative Service using a Knative Service manifest
- Execute some Knative cli (`kn`) and `kubectl` commands to see the effects

## Prerequisites

### Cluster Up and Running

Please ensure that the `knative` cluster is running. If it's not, either restart it or re-create it
```shell
kubectl cluster-info
```
```text
Kubernetes control plane is running at https://127.0.0.1:62330
CoreDNS is running at https://127.0.0.1:62330/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```shell
kind get clusters
```
```text
knative
```

### Docker registry available (and accessble for public pulls)

IMPORTANT CHANGE!

I discovered an issue with Knative Serving that it cannot pull from the local docker registry. 
Knative Serving does a check to see if it can connect to the registry, but uses an `https` scheme. Interestingly, 
the Knative Function had no problem using it.

To work around this, I created a Docker Hub account and set it to allow public access for pulls.

You can either use your own repository, or use the `stlserverless` repo to pull our workshop image from. 
(You won't be able to push to it though.)

## Lab Steps

Since the all the code goodies are in the `hello-serving`, let's go to a 
[local markdown file](hello-serving/local_lab_steps.md), so we can execute the commands from markdown.

## Coming Up

With 
