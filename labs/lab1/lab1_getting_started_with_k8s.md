# Getting Started with ks3 / k8s

## Prerequisites

- `kind` [installed](../../setup_instructions/tools/kind.md) 
- `kubectl` [installed]((../../setup_instructions/tools/kubectl.md)) or available (Rancher Desktop installs it)

> Notes:
> 1. To avoid headaches, move, rename, or delete any existing `~/.kube` directory before proceeding!
> 2. You may see different resource names or states from one command execution to another. Don't focus on 
> these inconsistencies too much. They are the result of commands being executed at different times, 
> after resources have been deleted and recreated, after clusters have been destroyed and recreated, etc.

## Lab Steps

### Step 0 - Create a fresh cluster

```shell
kind create cluster --name stls-knative-workshop
```
```text
Creating cluster "stls-knative-workshop" ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-stls-knative-workshop"
You can now use your cluster with:

kubectl cluster-info --context kind-stls-knative-workshop

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```

### Step 1: Review available `kubectl` top level commands

> Note: You may see me use a `kc` alias I set to shortcut typing out the full `kubectl` name, i.e. `alias kc=kubectl`

```shell
kubectl
```
```text
kubectl controls the Kubernetes cluster manager.

 Find more information at: https://kubernetes.io/docs/reference/kubectl/

Basic Commands (Beginner):
  create          Create a resource from a file or from stdin
  expose          Take a replication controller, service, deployment or pod and expose it as a new Kubernetes service
  run             Run a particular image on the cluster
  set             Set specific features on objects

Basic Commands (Intermediate):
  explain         Get documentation for a resource
  get             Display one or many resources
  edit            Edit a resource on the server
  delete          Delete resources by file names, stdin, resources and names, or by resources and label selector

Deploy Commands:
  rollout         Manage the rollout of a resource
  scale           Set a new size for a deployment, replica set, or replication controller
  autoscale       Auto-scale a deployment, replica set, stateful set, or replication controller

Cluster Management Commands:
  certificate     Modify certificate resources.
  cluster-info    Display cluster information
  top             Display resource (CPU/memory) usage
  cordon          Mark node as unschedulable
  uncordon        Mark node as schedulable
  drain           Drain node in preparation for maintenance
  taint           Update the taints on one or more nodes

Troubleshooting and Debugging Commands:
  describe        Show details of a specific resource or group of resources
  logs            Print the logs for a container in a pod
  attach          Attach to a running container
  exec            Execute a command in a container
  port-forward    Forward one or more local ports to a pod
  proxy           Run a proxy to the Kubernetes API server
  cp              Copy files and directories to and from containers
  auth            Inspect authorization
  debug           Create debugging sessions for troubleshooting workloads and nodes

Advanced Commands:
  diff            Diff the live version against a would-be applied version
  apply           Apply a configuration to a resource by file name or stdin
  patch           Update fields of a resource
  replace         Replace a resource by file name or stdin
  wait            Experimental: Wait for a specific condition on one or many resources
  kustomize       Build a kustomization target from a directory or URL.

Settings Commands:
  label           Update the labels on a resource
  annotate        Update the annotations on a resource
  completion      Output shell completion code for the specified shell (bash, zsh, fish, or powershell)

Other Commands:
  alpha           Commands for features in alpha
  api-resources   Print the supported API resources on the server
  api-versions    Print the supported API versions on the server, in the form of "group/version"
  config          Modify kubeconfig files
  plugin          Provides utilities for interacting with plugins
  version         Print the client and server version information

Usage:
  kubectl [flags] [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

### Step 2: Review the cluster config using `kubectl`:

```shell
kubectl config view
```
```text
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://127.0.0.1:52673
  name: kind-stls-knative-workshop
contexts:
- context:
    cluster: kind-stls-knative-workshop
    user: kind-stls-knative-workshop
  name: kind-stls-knative-workshop
current-context: kind-stls-knative-workshop
kind: Config
preferences: {}
users:
- name: kind-stls-knative-workshop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```

### Step 3: Review the K8s config file:

```shell
cat ~/.kube/config
```

Notice you see the same info, but this time the certs aren't redacted.

> Tip: Prefer to manage the cluster through kubectl rather than editing the file.
> To see what cluster config commands are available, simply run `kubectl config`

### Step 4: Pods and ReplicaSets

The smallest unit of application deployment in K8s is a **_Pod_**. A Pod will contain 
one or more containers. However, we don't deploy pods directly. Instead, we create a _deployment_ 
that will deploy our pod.

When a pod deployment is created, a _ReplicaSet_ first gets created. A ReplicaSet's job is to ensure
a stable set of Pod replicas is maintained. If a Pod dies, the ReplicaSet will take steps to create another.

Let's deploy an Nginx pod into our cluster. Our deployment will be named `my-nginx`.

```shell
kubectl create deployment my-nginx --image=nginx
```
```text
deployment.apps/my-nginx created
```
*Congratulations! You've just created your first Kubernetes resource.*

```shell
kubectl get pods
```
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-pj4g2   1/1     Running   0          12s
```
This tells use we have our `my-nginx` deployment is ready and running with no restarts. The `READY` state of 
1/1 means 1 container is running in 1 Pod. If we had a _sidecar_ container running, we'd see READY state as 2/1.

We see our deployment name, `my-nginx` is the prefix, but what is that next value `b8dd4cd6`? That is the 
ReplicaSet id. We can see this running:
```shell
kubectl get replicaset
```
```text
NAME                DESIRED   CURRENT   READY   AGE
my-nginx-b8dd4cd6   1         1         1       44s
```
This tells us the replica set name is our deployment name + a hash value, i.e. `my-nginx-5987c6f9b8`. The 
_desired state_ of the Nginx replicas is 1 Pod instance, we have 1 instance currently, and it is Ready.

### Step 5: Manual scaling up pods

Let's scale our deployment from one pod to three.
```shell
kubectl scale --replicas=3 deployment/my-nginx
```
```text
deployment.apps/my-nginx scaled
```
Let's see the effect on the ReplicaSet:
```shell
kubectl get replicaset
```
```text
NAME                DESIRED   CURRENT   READY   AGE
my-nginx-b8dd4cd6   3         3         3       70s
```
And now the Pods...

```shell
kubectl get pods
```
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-m6mlq   1/1     Running   0          39s
my-nginx-b8dd4cd6-pj4g2   1/1     Running   0          103s
my-nginx-b8dd4cd6-ttwgc   1/1     Running   0          39s
```
We see our `my-nginx` deployment now has one ReplicaSet named `my-nginx-b8dd4cd6`, with 3 pods ready and 
running. The suffix of the Pod's full name is a shorter hash value, e.g. `m6mlq`, `pj4g2`, `ttwgc`.

### Step 6: See the effect of a pod dying

Open a new terminal window and run this command:
```shell
kubectl get pods -w
```
(I had already killed one which is why we see a different list here.)
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-m6mlq   1/1     Running   0          5m7s
my-nginx-b8dd4cd6-ttwgc   1/1     Running   0          5m7s
my-nginx-b8dd4cd6-zpdvl   1/1     Running   0          2m59s
```

Now, pick one of the pods and kill it by running this command command in a new terminal window (be sure to use the actual full name of one of your running pods):
```shell
kubectl delete pod my-nginx-b8dd4cd6-ttwgc
```
You'll see a series of pod status changes like this:
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-m6mlq   1/1     Running   0          5m7s
my-nginx-b8dd4cd6-ttwgc   1/1     Running   0          5m7s
my-nginx-b8dd4cd6-zpdvl   1/1     Running   0          2m59s
my-nginx-b8dd4cd6-ttwgc   1/1     Terminating   0          6m9s
my-nginx-b8dd4cd6-4kwwm   0/1     Pending       0          0s
my-nginx-b8dd4cd6-4kwwm   0/1     Pending       0          0s
my-nginx-b8dd4cd6-4kwwm   0/1     ContainerCreating   0          0s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m9s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-4kwwm   1/1     Running             0          2s
```

First, `my-nginx-b8dd4cd6-ttwgc` starts terminating.
```text
my-nginx-b8dd4cd6-ttwgc   1/1     Terminating   0          16m
```
The ReplicaSet detects a pod has died and wants the cluster to get back to the _desired state_ of 3 replicas, 
so it starts a new pod replica:
```text
my-nginx-b8dd4cd6-4kwwm   0/1     Pending       0          0s
my-nginx-b8dd4cd6-4kwwm   0/1     Pending       0          0s
my-nginx-b8dd4cd6-4kwwm   0/1     ContainerCreating   0          0s
```

Meanwhile, the killed pod container has stooped and the cluster finishes terminating the pod
```text
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m9s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
```

Finally, the new pod is fully up and running:
```text
my-nginx-b8dd4cd6-4kwwm   1/1     Running             0          2s
```

We can verify the new, final state:
```shell
kubectl get pods
```
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-4kwwm   1/1     Running   0          99s
my-nginx-b8dd4cd6-m6mlq   1/1     Running   0          7m48s
my-nginx-b8dd4cd6-zpdvl   1/1     Running   0          5m40s
```

On my Mac, this all happened in a matter of seconds.

### Step 7: Manually scaling down

Of course, we can scale the number of Pod replicas down as well.
```shell
kubectl scale --replicas=2 deployment/my-nginx
```
```text
deployment.apps/my-nginx scaled
```

If your watch terminal window is still open, you'll see something like this:
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-m6mlq   1/1     Running   0          5m7s
my-nginx-b8dd4cd6-ttwgc   1/1     Running   0          5m7s
my-nginx-b8dd4cd6-zpdvl   1/1     Running   0          2m59s
my-nginx-b8dd4cd6-ttwgc   1/1     Terminating   0          6m9s
my-nginx-b8dd4cd6-4kwwm   0/1     Pending       0          0s
my-nginx-b8dd4cd6-4kwwm   0/1     Pending       0          0s
my-nginx-b8dd4cd6-4kwwm   0/1     ContainerCreating   0          0s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m9s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-ttwgc   0/1     Terminating         0          6m10s
my-nginx-b8dd4cd6-4kwwm   1/1     Running             0          2s
my-nginx-b8dd4cd6-4kwwm   1/1     Terminating         0          2m4s
my-nginx-b8dd4cd6-4kwwm   0/1     Terminating         0          2m4s
my-nginx-b8dd4cd6-4kwwm   0/1     Terminating         0          2m4s
my-nginx-b8dd4cd6-4kwwm   0/1     Terminating         0          2m4s
my-nginx-b8dd4cd6-4kwwm   0/1     Terminating         0          2m4s
```

Verifying final state is easy:
```shell
kubectl get pods
```
```text
NAME                      READY   STATUS    RESTARTS   AGE
my-nginx-b8dd4cd6-m6mlq   1/1     Running   0          8m43s
my-nginx-b8dd4cd6-zpdvl   1/1     Running   0          6m35s
```

### Step 8: Deleting a deployment

To delete a deployment, run:
```shell
kubectl delete deployment my-nginx
```
```text
deployment.apps "my-nginx" deleted
```
Verify:
```shell
kubectl get pods
```
```text
No resources found in default namespace.
```
### Step 9: Work with namespaces

That last message reveals everything we've done so far has been in our cluster's `default` namespace. That's 
okay for experimentation or small applications. However, larger projects with multiple teams, many 
resources, all deployed to different environments, will soon find the `default` workspace is unmanageable.

We may want to create different namespaces for:
- Each team
- Each environment
- Each category of resource (database, logging and monitoring, etc.)

Let's see what namespaces we have by _out of the box_:

```shell
kubectl get namespace
```
```shell
NAME                 STATUS   AGE
default              Active   11m
kube-node-lease      Active   11m
kube-public          Active   11m
kube-system          Active   11m
local-path-storage   Active   11m
```

Now, create a new namespace.

```shell
kubectl create namespace stls-workshop
```
```text
namespace/stls-workshop created
```

Check it out:
```shell
kubectl get namespace
```
```shell
NAME                 STATUS   AGE
default              Active   12m
kube-node-lease      Active   12m
kube-public          Active   12m
kube-system          Active   12m
local-path-storage   Active   12m
stls-workshop        Active   4s
```

### Step 10: Deploy a 4-Pod replica set into our stls-workshop namespace in a deployment named team1-nginx

First, run the following command in a new terminal window:
```shell
kubectl get pods --namespace=stls-workshop -w
```

Then, run the following command:
```shell
kubectl create deployment team1-nginx --image=nginx --replicas=4 --namespace=stls-workshop
```

Observe in the watch window:
```text
NAME                          READY   STATUS    RESTARTS   AGE
team1-nginx-9dd76dbf6-qcbfl   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-pfh8k   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-kvsvp   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-qcbfl   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-pfh8k   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-4cbjs   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-kvsvp   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-4cbjs   0/1     Pending   0          0s
team1-nginx-9dd76dbf6-qcbfl   0/1     ContainerCreating   0          0s
team1-nginx-9dd76dbf6-pfh8k   0/1     ContainerCreating   0          0s
team1-nginx-9dd76dbf6-kvsvp   0/1     ContainerCreating   0          0s
team1-nginx-9dd76dbf6-4cbjs   0/1     ContainerCreating   0          0s
team1-nginx-9dd76dbf6-pfh8k   1/1     Running             0          1s
team1-nginx-9dd76dbf6-kvsvp   1/1     Running             0          2s
team1-nginx-9dd76dbf6-qcbfl   1/1     Running             0          2s
team1-nginx-9dd76dbf6-4cbjs   1/1     Running             0          2s
```

### Step 11: Describe a Deployment

Run this command:
```shell
kubectl describe deployment/team1-nginx -n stls-workshop
```
```text
Name:                   team1-nginx
Namespace:              stls-workshop
CreationTimestamp:      Sun, 09 Jul 2023 23:58:11 -0500
Labels:                 app=team1-nginx
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=team1-nginx
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=team1-nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   team1-nginx-9dd76dbf6 (4/4 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  43s   deployment-controller  Scaled up replica set team1-nginx-9dd76dbf6 to 4
```

### Step 12: Infrastructure as Code - Generating a YAML manifest

So far, we've been using the command line to do all our work. This is fine for quick experiments, but is not 
really a modern SDLC (Software Development Lifecycle) approach. We should prefer a source-controlled, pull-requestable
approach to configuring our Kubernetes cluster.

A Kubernetes _manifest_ is a YAML file that describes the _desired state_ of resource(s). For this workshop, we'll 
use manifest files. However, as I really hate writing YAML file, I'll use the command line when I can to generate the 
basic yaml manifest, then tweak it as needed.

To get started, first let's start with a clean slate. Execute this command to delete our existing deployment:
```shell
kubectl delete deployment/team1-nginx -n stls-workshop
```

We'll use the same command line to create the deployment, but won't actually deploy anything.

> Execute the following commands from the labs/lab1 directory

```shell
kubectl create deployment team1-nginx --image=nginx --replicas=4 --namespace=stls-workshop --dry-run=client -o yaml > team1-nginx.yaml 
```
Here's the contents of the generate file named `team1-nginx.yaml`:
```text
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: team1-nginx
  name: team1-nginx
  namespace: stls-workshop
spec:
  replicas: 4
  selector:
    matchLabels:
      app: team1-nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: team1-nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

Nice! Before committing it, let's clean out the parts we don't want to commit.
- Remove the two (2) `creationTimestamp: null` fields
- Remove the `strategy: {}` field
- Remove the `resources: {}` field
- Remove the `status: {}` field

This is what's left:
```text
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: team1-nginx
  name: team1-nginx
  namespace: stls-workshop
spec:
  replicas: 4
  selector:
    matchLabels:
      app: team1-nginx
  template:
    metadata:
      labels:
        app: team1-nginx
    spec:
      containers:
      - image: nginx
        name: nginx
```

Let's test our work by using the file:
```shell
kubectl apply -f team1-nginx.yaml
```
```text
deployment.apps/team1-nginx created
```
Verify we got what we expected:
```shell
kubectl get pods -n stls-workshop
```
```text
NAME                          READY   STATUS    RESTARTS   AGE
team1-nginx-9dd76dbf6-j94w5   1/1     Running   0          8s
team1-nginx-9dd76dbf6-ldjv6   1/1     Running   0          8s
team1-nginx-9dd76dbf6-sjc2l   1/1     Running   0          8s
team1-nginx-9dd76dbf6-tk4v2   1/1     Running   0          8s
```

Nice!

### Step 13: Apply an updated manifest

Let's change our deployment's _desired state_ to have two replicas. Change the `replicas` field to be 2 like below:
```text
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: team1-nginx
  name: team1-nginx
  namespace: stls-workshop
spec:
  replicas: 2
  selector:
    matchLabels:
      app: team1-nginx
  template:
    metadata:
      labels:
        app: team1-nginx
    spec:
      containers:
      - image: nginx
        name: nginx
```

Now, run `apply` again using the same file:
```shell
kubectl apply -f team1-nginx.yaml
```
```text
deployment.apps/team1-nginx configured
```
Notice the output is "deployment.apps/team1-nginx **configured**" not "deployment.apps/team1-nginx **created**".

Let's verify our updated deployment:
```shell
kubectl get pods -n stls-workshop
```
```text
NAME                          READY   STATUS    RESTARTS   AGE
team1-nginx-9dd76dbf6-j94w5   1/1     Running   0          49s
team1-nginx-9dd76dbf6-tk4v2   1/1     Running   0          49s
```

The manifest file represents our current state and its changes can be committed into source control.

Bonus: If you'd like to see the whole deployment (this time in json prettified with jq), try this:
```shell
kubectl get deployment team1-nginx -n stls-workshop -o json | jq
```

### Step 14: Accessing our microservice from outside the cluster via an Ingress

Kubernetes provides excellent network support and isolation. When we create a deployment, the Pod replicas each 
get a private IP address based on the Node they're running on, along with any declared ports they exposed so 
other services on the network can access them. We can see the Pod IP addresses using wide output:

```shell
kubectl get pods -o wide -n stls-workshop
```
```text
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE                                  NOMINATED NODE   READINESS GATES
team1-nginx-9dd76dbf6-j94w5   1/1     Running   0          83s   10.244.0.14   stls-knative-workshop-control-plane   <none>           <none>
team1-nginx-9dd76dbf6-tk4v2   1/1     Running   0          83s   10.244.0.16   stls-knative-workshop-control-plane   <none>           <none>
```
Unfortunately, we don't really want to address each Pod in a replica by its IP address. Pods are ephemeral, and 
are expected to come into existence and be destroyed by normal auto-scaling actions. We really don't want to have 
to call back to the Kubernetes API Server to get a list of valid Pod IPs every time we're about to call an endpoint 
on the Pod.

Also, by default, we can't access these from outside the cluster. Try it and see:
```shell
curl 10.244.0.14:80
```

After a few minutes, you will get the error
```text
Failed to connect to 10.244.0.14 port 80 after 75004 ms: Couldn't connect to server
```

Kubernetes solves this by giving us a Service resource that acts as a load balancer for Pods in a ReplicaSet. 
(Remember, all pods are in a ReplicaSet, even if replicas = 1.) A Service exposes a single, unchanging IP address 
to access its Pods.   

Services come in these types:
- ClusterIP (default): Service IP is internal to the cluster only. Can access the service via an Ingress or Gateway
- NodePort: Exposes the Service on each Node's IP at a static port in the range of 30000-32767
- LoadBalancer: Exposes the Service externally using an external load balancer (not provided by Kubernetes)
- ExternalName: Maps the Service to the contents of the externalName field

Generally, NodePort is considered a bad security practice as you're literally opening up port(s) on your nodes.

Fortunately, `kind` comes with way to expose ports for a cluster ingress.

Let's delete the existing cluster and start fresh.
```shell
kind delete cluster -n stls-knative-workshop
```

Now create a new cluster using a shell command:
```shell
cat <<EOF | kind create cluster --name stls-knative-workshop --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

With a cluster created, we'll create an Ingress:
```shell
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```
```text
namespace/projectcontour created
serviceaccount/contour created
serviceaccount/envoy created
configmap/contour created
customresourcedefinition.apiextensions.k8s.io/contourconfigurations.projectcontour.io created
customresourcedefinition.apiextensions.k8s.io/contourdeployments.projectcontour.io created
customresourcedefinition.apiextensions.k8s.io/extensionservices.projectcontour.io created
customresourcedefinition.apiextensions.k8s.io/httpproxies.projectcontour.io created
customresourcedefinition.apiextensions.k8s.io/tlscertificatedelegations.projectcontour.io created
serviceaccount/contour-certgen created
rolebinding.rbac.authorization.k8s.io/contour created
role.rbac.authorization.k8s.io/contour-certgen created
Warning: metadata.name: this is used in Pod names and hostnames, which can result in surprising behavior; a DNS label is recommended: [must not contain dots]
job.batch/contour-certgen-v1.25.0 created
clusterrolebinding.rbac.authorization.k8s.io/contour created
rolebinding.rbac.authorization.k8s.io/contour-rolebinding created
clusterrole.rbac.authorization.k8s.io/contour created
role.rbac.authorization.k8s.io/contour created
service/contour created
service/envoy created
deployment.apps/contour created
daemonset.apps/envoy created
```

We need to apply `kind` specific patches to forward the hostPorts to the ingress controller, 
set taint tolerations, and schedule it to the custom labeled node.
```shell
kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Equal","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
```
```text
daemonset.apps/envoy patched
```

Next, let's create our namespace:
```shell
kubectl create namespace stls-workshop
```
```text
namespace/stls-workshop created
```

Now, review the `team1-nginx-with-ingress.yaml` file. Unlike earlier examples configuring one resource, 
in this one YAML file we configure three resources in the `stls-workshop`:
- A deployment with two Pods for Nginx (all get a private cluster IP address)
- A service (default type = ClusterIP) that is an internal load balancer for our two pods
- An Ingress resource defining rules for requests sent into port 80 for our Service

Deploy the resources by running:
```shell
kubectl apply -f team1-nginx-with-ingress.yaml
```
```text
deployment.apps/nginx-app created
service/nginx-app-service created
ingress.networking.k8s.io/nginx-ingress created
```

After a few seconds, you can run 
```shell
curl localhost
```
You should see this response:
```text
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Step 15 - (Optional Bonus) Installing Your Container Registry Secret

> Note: We'll be using the local registry running at localhost:5001. It's not secured, so this step isn't needed.
> I provide these instructions in case later you want to work with a private registry, like Docker or GitHub

When we deploy a Knative Service or Function, the image will be pushed to the specified repository on your registry
service; e.g. Docker, GitHub, Google, AWS, localhost, etc.

If the repository is private, as will likely be the case in your organizations, Kubernetes will need to know how to
authenticate to that registry and access your image repository.

To do that, we need to register a _Secret_.

> Note: It's not really secret, just a Base64 encoded representation of your credentials. If you want encrypted secrets,
> you'll need to take extra steps beyond the scope of this workshop.

If your image repository is private, you have a little extra pain to set up access for the cluster. I have my
Docker account to default to create private image repos.

A Kubernetes Secret is a sort-of secret thing that can store credentials, etc. that are needed by services.
When we do a deployment, if the image being pulled is in a proivate repo, you'll need to create a secret
that can be used to authenticate with the container registry.

Note that Secrets are namespaced; that is, a Deployment into namespace A won't use a Secret defined for namespace B.

First, review the
[knative private registry instructions](https://knative.dev/docs/serving/deploying-from-private-registry/#procedure)
and execute them so your Knative deployments can use your private registry.

I'll summarize the steps here.

Create the Secret:
```text
kubectl create secret docker-registry container-registry \
  --docker-server=https://docker.io/ \
  --docker-email=my-account-email@address.com \
  --docker-username=my-docker-username \
  --docker-password=my-docker-username-or-pat
```
( The `container-registry` is an arbitrary name.)

> Note: If you're using MFA, the password needs to be a Personal Access Token with read/write/delete permissions.

I've defined the replaceable values in environment variables, so I can run:
```shell
kubectl create secret -n default docker-registry container-registry \
  --docker-server=$DOCKER_REGISTRY \
  --docker-email=$DOCKER_EMAIL \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_RWD_PAT
```

IMPORTANT! Patch the service account used in the namespace. (We'll stick with the `default` namespace in the
rest of the labs.)

```shell
kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"container-registry\"}]}"
```

> Note: On a specific deployment, you can specify this secret is to be used to pull the image from the private repo:
```text
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    spec:
      imagePullSecrets:
      - name: container-registry
      containers:
        - image: ghcr.io/knative/helloworld-go:latest
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World"
```

### Step 16 - Cleanup

As a final step, let's delete the Lab1 cluster:
```shell
kind delete cluster -n stls-knative-workshop
```

Verify the `kind` container is gone, but notice the registry container is still running:
```shell
docker ps -a
```
```text
CONTAINER ID   IMAGE        COMMAND                  CREATED       STATUS             PORTS                      NAMES
74bedb122e9a   registry:2   "/entrypoint.sh /etc…"   2 hours ago   Up About an hour   127.0.0.1:5001->5000/tcp   kind-registry
```

(We'll use the registry, so don't bother cleaning it up now.)

## Coming up

In this lab, we've taken a whirlwind tour of working with Kubernetes 
using `kind` running Kubernetes as a Docker container.

We've used a few `kubectl`commands to create and manage resources in our cluster. We've also seen how we can use 
manifest files to capture and preserve the resource configurations. Finally, we saw how 
we can give access to our Services using an Ingress.

I don't mean to scare you, but we barely scratched the surface of Kubernetes. Fortunately,
one of the goals of Knative is to abstract away all the many, many, many details of Kubernetes 
to allow teams to focus on developing applications and managing their deployments in a serverless 
architecture.

Lab 2 will build on these steps as we first install Knative.
