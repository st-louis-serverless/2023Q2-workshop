# Lab 2 - Getting Started with Knative Using `kind`

Knative offers three capabilities:
- Knative Functions
- Knative Serving
- Knative Eventing

I wish I could say installing Knative is a trivial task. It is not. See the 
[docs](lab2_getting_started_with_knative_with_k3d.md) for details steps using `k3d`. 
Be prepared for some DNS issues though.

For this workshop, we'll use the Knative Quickstart to install the Knative capabilities, but first, 
we'll need a new cluster since we deleted the one we used in Lab 1.

> Important: Most of the `kubectl` commands used below assume they are executed from the `labs/lab2` folder. 

## Prerequisites

These must be installed:

- [kind](../../setup_instructions/tools/kind.md)
- [kubectl](../../setup_instructions/tools/kubectl.md)
- [Knative tools](../../setup_instructions/tools/kn_tools.md)

## Lab Steps

### Step 1 - Install Knative into `kind` using the Quickstart plugin

```shell
kn quickstart kind
```
```text
Running Knative Quickstart using Kind
✅ Checking dependencies...
    Kind version is: 0.20.0

☸ Creating Kind cluster...
Creating cluster "knative" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Waiting ≤ 2m0s for control-plane = Ready ⏳ 
 • Ready after 19s 💚
Set kubectl context to "kind-knative"
You can now use your cluster with:

kubectl cluster-info --context kind-knative

Have a nice day! 👋

🍿 Installing Knative Serving v1.10.0 ...
    CRDs installed...
    Core installed...
    Finished installing Knative Serving
🕸️ Installing Kourier networking layer v1.10.0 ...
    Kourier installed...
    Ingress patched...
    Finished installing Kourier Networking layer
🕸 Configuring Kourier for Kind...
    Kourier service installed...
    Domain DNS set up...
    Finished configuring Kourier
🔥 Installing Knative Eventing v1.10.0 ... 
    CRDs installed...
    Core installed...
    In-memory channel installed...
    Mt-channel broker installed...
    Example broker installed...
    Finished installing Knative Eventing
🚀 Knative install took: 2m10s 
🎉 Now have some fun with Serverless and Event Driven Apps!
```

Verify it with:
```shell
kind get clusters
```
```text
knative
```

Get cluster info:
```shell
kubectl cluster-info --context kind-knative
```
```text
Kubernetes control plane is running at https://127.0.0.1:51351
CoreDNS is running at https://127.0.0.1:51351/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### Step 2 - Review Knative Serving Install

After a few seconds, verify the deployment by executing this command:
```shell
kubectl get deployment -n knative-serving
```
```text
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
activator                1/1     1            1           3m45s
autoscaler               1/1     1            1           3m45s
controller               1/1     1            1           3m45s
domain-mapping           1/1     1            1           3m45s
domainmapping-webhook    1/1     1            1           3m45s
net-kourier-controller   1/1     1            1           3m29s
webhook                  1/1     1            1           3m45s
```

### Step 3 - Review Knative Eventing Install

```shell
kubectl get deployment -n knative-eventing
```
```text
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
eventing-controller     1/1     1            1           8m23s
eventing-webhook        1/1     1            1           8m23s
imc-controller          1/1     1            1           7m52s
imc-dispatcher          1/1     1            1           7m52s
mt-broker-controller    1/1     1            1           7m45s
mt-broker-filter        1/1     1            1           7m45s
mt-broker-ingress       1/1     1            1           7m45s
pingsource-mt-adapter   0/0     0            0           8m23s
```
(Don't worry about that `pingsource-mt-adapter` not starting. We didn't configure it to be used.)

## Coming Up

Lab 2 illustrated the very simple create / code / test / deploy model offered by Knative Functions. In Lab 4, we'll
dive into Knative Serving and explore the various deployment and traffic splitting options.
