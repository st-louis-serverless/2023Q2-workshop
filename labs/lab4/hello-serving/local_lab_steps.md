# Lab 4 - Knative Serving (local)

## Lab Steps

### Step 1 - Review the code

In the `hello-serving` directory, there is a Typescript project that makes a simple `hello` Node Express app that
outputs some basic info when a GET request comes in.

#### Application source file

Let's review the [source file](src/index.ts):
```typescript
import express from 'express'

const app = express()

const sleep = (ms: number): Promise<void> => {
  return new Promise(resolve => setTimeout(resolve, ms));
}

app.get('/', async (req, res) => {
  console.log('Hello service received a request.')

  const target = process.env.TARGET || 'STLS'

  const latency = Number(process.env.DELAY) || 1000
  await sleep(latency)

  const now = new Date().toLocaleString('en-US', {
    hour: 'numeric', // numeric, 2-digit
    minute: 'numeric', // numeric, 2-digit
    second: 'numeric', // numeric, 2-digit
    hour12: false,
  })

  const index = req.query.index
  const prefix = index !== undefined ? `${index}: ${now} - ` : ''

  res.send(`${prefix}Hello ${target}\n`)
})

const port = process.env.PORT || 8080

app.listen(port, () => {
  console.log('Hello service listening on port', port)
})
```

We see it outputs a "Hello" message prefixed with a timestamp or supplied index value.

#### Dockerfile

We'll build an image using a [Dockerfile](Dockerfile):

```dockerfile
# Use the official lightweight Node.js 18 image.
# https://hub.docker.com/_/node
FROM node:18.6.0-slim

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install production dependencies.
RUN npm install

# Copy local code to the container image.
COPY bin ./

# Run the web service on container startup.
ENTRYPOINT [ "npm", "start" ]
```

#### Knative Service manifest

While we could deploy this simple service using the `kn` commandline tool, we'll opt for a more standard,
_Infrastructure as Code_ approach and use a [manifest](hello-stls.yaml).
```text
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-stls
  namespace: default
spec:
  template:
    metadata:
      annotations:
        # We'll set the autoscaling dynamically using kn service update, but you can do it here
        # autoscaling.knative.dev/minScale: "1"
        # autoscaling.knative.dev/maxScale: "10"
    spec:
      # Basically, how many concurrent requests can this service handle?
      # The default value is 0, meaning that there is no limit on the number of requests
      # that are allowed to flow into the revision. A value greater than 0 specifies the
      # exact number of requests that are allowed to flow to the replica at any one time.
      # For demoing autoscaling, I'll set it to some non-zero value
      containerConcurrency: 10
      containers:
        - image: stlserverless/hello-stls:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "STLS"
```

Let's do it!

> IMPORTANT: These commands are assumed to be executed from inside the `hello-serving` directory. Otherwise, you'll get:
> ERR_PNPM_NO_IMPORTER_MANIFEST_FOUND  No package.json (or package.yaml, or package.json5)
> was found in "/Users/jackfrosch/swdev/data/projects/stl-serverless/2023Q2-workshop/labs/lab4"

### Step 2 - Build and push an image

> Note: I'm actually using `pnpm` aliased to npm
First, use `npm` to install the dependencies:
```shell
npm install
```

Then, use `npm` to build it:
```shell
npm run build
```

If there are no errors, we build the Docker image
```shell
docker build . -t hello-stls
```

Verify it:
```shell
docker images hello-stls
```

Tag it for our local registry:
```shell
docker tag hello-stls:latest stlserverless/hello-stls:latest
```

Login to Docker (if not already):
```shell
docker login -u stlserverless -p $STLS_PAT
```

If all is well, push it to the local registry:
```shell
docker push stlserverless/hello-stls:latest
```

Verify:
```shell
docker images stlserverless/hello-stls
```

### Step 3 - Create a Knative Service

We'll use the `kn` cli to create the service. It's akin to `kubectl apply`.
```shell
kn service create hello-stls --filename hello-stls.yaml --force
```
```text
Warning: Kubernetes default value is insecure, Knative may default this to secure in a future release: spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation, spec.template.spec.containers[0].securityContext.capabilities, spec.template.spec.containers[0].securityContext.runAsNonRoot, spec.template.spec.containers[0].securityContext.seccompProfile
Creating service 'hello-stls' in namespace 'default':

  0.012s The Route is still working to reflect the latest desired specification.
  0.030s Configuration "hello-stls" is waiting for a Revision to become ready.
  1.108s ...
  1.116s Ingress has not yet been reconciled.
  1.140s Waiting for load balancer to be ready
  1.334s Ready to serve.

Service 'hello-stls' created to latest revision 'hello-stls-00001' is available at URL:
http://hello-stls.default.127.0.0.1.sslip.io
```

Test it:
```shell
curl http://hello-stls.default.127.0.0.1.sslip.io
```
```text
Hello STLS
```

Check out the kn services:
```shell
kn service list
```
```text
NAME         URL                                            LATEST             AGE    CONDITIONS   READY   REASON
hello-stls   http://hello-stls.default.127.0.0.1.sslip.io   hello-stls-00001   2m5s   3 OK / 3     True
```

Let's examine the service in detail:
```shell
kn service describe hello-stls
```
```text
Name:       hello-stls
Namespace:  default
Age:        5m
URL:        http://hello-stls.default.127.0.0.1.sslip.io

Revisions:  
  100%  @latest (hello-stls-00001) [1] (5m)
        Image:     stlserverless/hello-stls:latest (at 824a2e)
        Replicas:  0/0

Conditions:  
  OK TYPE                   AGE REASON
  ++ Ready                   5m 
  ++ ConfigurationsReady     5m 
  ++ RoutesReady             5m
```

Let's explore the route(s) created:
```shell
kn route describe hello-stls
```
```text
Name:       hello-stls
Namespace:  default
Age:        7m
URL:        http://hello-stls.default.127.0.0.1.sslip.io
Service:    hello-stls

Traffic Targets:  
  100%  @latest (hello-stls-00001)

Conditions:  
  OK TYPE                      AGE REASON
  ++ Ready                      7m 
  ++ AllTrafficAssigned         7m 
  ++ CertificateProvisioned     7m TLSNotEnabled
  ++ IngressReady               7m
```

```shell
kn revision list
```
```text
NAME               SERVICE      TRAFFIC   TAGS   GENERATION   AGE    CONDITIONS   READY   REASON
hello-stls-00001   hello-stls   100%             1            2m8s   4 OK / 4     True
```

Check out the pods:
```shell
kubectl get pods
```
```text
NAME                                           READY   STATUS        RESTARTS   AGE
hello-stls-00001-deployment-598478fc9b-2bvnj   2/2     Terminating   0          75s
```

> Notice after a few seconds with no requests, the pod is already terminating since it's configured to scale 
to 0 by default.

### Step 4 - Scaling a Knative Service

In this step, we wil update the service to use up to 5 instances, then pump 100 messages to it.

List the revisions:
```shell
kn revision list
```
```text
NAME               SERVICE      TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-stls-00001   hello-stls   100%             1            12m   3 OK / 4     True
```

Change the configuration. Recall, this will result in a new revision:
```shell
kn service update hello-stls --scale 0..5
```
```text
Warning: ... (omitted)
Updating Service 'hello-stls' in namespace 'default':

  0.010s The Configuration is still working to reflect the latest desired specification.
  1.967s Traffic is not yet migrated to the latest revision.
  1.981s Ingress has not yet been reconciled.
  1.986s Waiting for load balancer to be ready
  2.186s Ready to serve.

Service 'hello-stls' updated to latest revision 'hello-stls-00002' is available at URL:
http://hello-stls.default.127.0.0.1.sslip.io
```

```shell
kn revision list
```
```text
NAME               SERVICE      TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-stls-00002   hello-stls   100%             2            61s   4 OK / 4     True    
hello-stls-00001   hello-stls                    1            14m   3 OK / 4     True
```
> Note how 100% of the traffic is going to the new revision.

Get the pods with -w:
```shell
kubectl get pods -w
```

Now, apply some load and flip over to the watching window:
```shell
zsh ./load_test.sh 
```
```text
NAME                                           READY   STATUS    RESTARTS   AGE
...
hello-stls-00002-deployment-648d8f45cd-967vd   2/2     Running   0          34s
hello-stls-00002-deployment-648d8f45cd-9rdns   2/2     Running   0          34s
hello-stls-00002-deployment-648d8f45cd-fzmfd   2/2     Running   0          34s
hello-stls-00002-deployment-648d8f45cd-tmldm   2/2     Running   0          34s
hello-stls-00002-deployment-648d8f45cd-wj2dm   2/2     Running   0          36s
... after a a minute or so ...
hello-stls-00002-deployment-648d8f45cd-wj2dm   2/2     Terminating   0          68s
hello-stls-00002-deployment-648d8f45cd-967vd   2/2     Terminating   0          66s
hello-stls-00002-deployment-648d8f45cd-tmldm   2/2     Terminating   0          66s
hello-stls-00002-deployment-648d8f45cd-fzmfd   2/2     Terminating   0          68s
hello-stls-00002-deployment-648d8f45cd-9rdns   2/2     Terminating   0          70s
hello-stls-00002-deployment-648d8f45cd-wj2dm   1/2     Terminating   0          91s
hello-stls-00002-deployment-648d8f45cd-tmldm   1/2     Terminating   0          90s
hello-stls-00002-deployment-648d8f45cd-967vd   1/2     Terminating   0          90s
hello-stls-00002-deployment-648d8f45cd-9rdns   1/2     Terminating   0          91s
hello-stls-00002-deployment-648d8f45cd-fzmfd   1/2     Terminating   0          91s
hello-stls-00002-deployment-648d8f45cd-967vd   0/2     Terminating   0          97s
hello-stls-00002-deployment-648d8f45cd-967vd   0/2     Terminating   0          97s
hello-stls-00002-deployment-648d8f45cd-967vd   0/2     Terminating   0          97s
hello-stls-00002-deployment-648d8f45cd-wj2dm   0/2     Terminating   0          99s
hello-stls-00002-deployment-648d8f45cd-wj2dm   0/2     Terminating   0          99s
hello-stls-00002-deployment-648d8f45cd-wj2dm   0/2     Terminating   0          99s
hello-stls-00002-deployment-648d8f45cd-tmldm   0/2     Terminating   0          97s
hello-stls-00002-deployment-648d8f45cd-tmldm   0/2     Terminating   0          97s
hello-stls-00002-deployment-648d8f45cd-tmldm   0/2     Terminating   0          97s
hello-stls-00002-deployment-648d8f45cd-fzmfd   0/2     Terminating   0          99s
hello-stls-00002-deployment-648d8f45cd-fzmfd   0/2     Terminating   0          99s
hello-stls-00002-deployment-648d8f45cd-fzmfd   0/2     Terminating   0          99s
hello-stls-00002-deployment-648d8f45cd-9rdns   0/2     Terminating   0          101s
hello-stls-00002-deployment-648d8f45cd-9rdns   0/2     Terminating   0          101s
hello-stls-00002-deployment-648d8f45cd-9rdns   0/2     Terminating   0          101s
```

### Step 5 - Revision tags and Traffic Routing

Any time we update the service, we get a new revision. We could do it all through a YAML config file, 
then use kubectl apply -f <filename>. However, the Knative CLI make doing so very easy. We like easy.

What can we do in an kn service update?
- apply new environment vars; e.g.: kn service update my-svc --env FFLAG_101=true
- make a revision using an updated image; e.g: kn service update my-svc --image some-repo/my-svc:build123
- make a revision from the latest; e.g: kn service update my-svc --revision-name ''

In this step, we'll make two revisions, one with `Feature Flag 1` set to `true` and 
one with the Feature Flag 1 set to `false`. We'll then require a 50/50 split in traffic between the two revisions.

```shell
kn revision list
```
```text
NAME               SERVICE      TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-stls-00002   hello-stls   100%             2            14m   3 OK / 4     True    ```
hello-stls-00001   hello-stls                    1            28m   3 OK / 4     True
```

Make a revision:
```shell
kn service update hello-stls --env TARGET="Feature Flag 1: True" --revision-name ff1t
```
```text
Warning: ...
Updating Service 'hello-stls' in namespace 'default':

  0.012s The Configuration is still working to reflect the latest desired specification.
  1.960s Traffic is not yet migrated to the latest revision.
  1.970s Ingress has not yet been reconciled.
  1.992s Waiting for load balancer to be ready
  2.178s Ready to serve.

Service 'hello-stls' updated to latest revision 'hello-stls-ff1t' is available at URL:
http://hello-stls.default.127.0.0.1.sslip.io
```

And another:
Make a revision:
```shell
kn service update hello-stls --env TARGET="Feature Flag 1: False" --revision-name ff1f
```
```text
Warning: ...
Updating Service 'hello-stls' in namespace 'default':

  0.011s The Configuration is still working to reflect the latest desired specification.
  1.356s Traffic is not yet migrated to the latest revision.
  1.371s Ingress has not yet been reconciled.
  1.382s Waiting for load balancer to be ready
  1.572s Ready to serve.

Service 'hello-stls' updated to latest revision 'hello-stls-ff1f' is available at URL:
http://hello-stls.default.127.0.0.1.sslip.io
```

Check the revisions:
```shell
kn revision list
```
```text
NAME               SERVICE      TRAFFIC   TAGS   GENERATION   AGE     CONDITIONS   READY   REASON
hello-stls-ff1f    hello-stls   100%             4            51s     4 OK / 4     True    
hello-stls-ff1t    hello-stls                    3            3m56s   3 OK / 4     True    
hello-stls-00002   hello-stls                    2            19m     3 OK / 4     True    
hello-stls-00001   hello-stls                    1            33m     3 OK / 4     True
```
Notice, the latest revision gets 100% of traffic by default. Let's change that.

```shell
kn service update hello-stls --tag hello-stls-ff1t=ff1t --tag hello-stls-ff1f=ff1f --traffic ff1t=50,ff1f=50
```
```text
Warning: ...
Updating Service 'hello-stls' in namespace 'default':

  0.010s The Route is still working to reflect the latest desired specification.
  0.028s Ingress has not yet been reconciled.
  0.034s Waiting for load balancer to be ready
  0.251s Ready to serve.

Service 'hello-stls' with latest revision 'hello-stls-ff1f' (unchanged) is available at URL:
http://hello-stls.default.127.0.0.1.sslip.io
```

Check the revisions now:
```shell
kn revision list
```
```text
NAME               SERVICE      TRAFFIC   TAGS   GENERATION   AGE     CONDITIONS   READY   REASON
hello-stls-ff1f    hello-stls   50%       ff1f   4            3m35s   3 OK / 4     True    
hello-stls-ff1t    hello-stls   50%       ff1t   3            6m40s   3 OK / 4     True    
hello-stls-00002   hello-stls                    2            22m     3 OK / 4     True    
hello-stls-00001   hello-stls                    1            36m     3 OK / 4     True
```
We will now get 50% going to ff1f and 50% going to ff1t.

Let's see how the route(s) were affected:
```shell
kn route describe hello-stls
```
```text
Name:       hello-stls
Namespace:  default
Age:        37m
URL:        http://hello-stls.default.127.0.0.1.sslip.io
Service:    hello-stls

Traffic Targets:  
   50%  hello-stls-ff1t #ff1t
        URL:  http://ff1t-hello-stls.default.127.0.0.1.sslip.io
   50%  hello-stls-ff1f #ff1f
        URL:  http://ff1f-hello-stls.default.127.0.0.1.sslip.io

Conditions:  
  OK TYPE                      AGE REASON
  ++ Ready                      2m 
  ++ AllTrafficAssigned        37m 
  ++ CertificateProvisioned    37m TLSNotEnabled
  ++ IngressReady               2m
```
Nice, huh?

Notice, we get very specific urls for each revision getting traffic. The URL is prefixed with the tag. This way, 
we can test a specific route for QA or if something went wrong, like, 
"Sales have dropped to $0.00 after turning FF1 on!!!!" 

Let's test each route:
```shell
curl http://ff1t-hello-stls.default.127.0.0.1.sslip.io
```
```text
Hello Feature Flag 1: True
```
```shell
curl http://ff1f-hello-stls.default.127.0.0.1.sslip.io
```
```text
Hello Feature Flag 1: False
```

Finally, let's throw some load at it.
```shell
zsh ./load_test.sh
```
```text
30: 24:39:19 - Hello Feature Flag 1: False
23: 24:39:19 - Hello Feature Flag 1: False
25: 24:39:19 - Hello Feature Flag 1: False
19: 24:39:19 - Hello Feature Flag 1: False
43: 24:39:19 - Hello Feature Flag 1: False
22: 24:39:19 - Hello Feature Flag 1: False
15: 24:39:19 - Hello Feature Flag 1: False
24: 24:39:19 - Hello Feature Flag 1: False
4: 24:39:19 - Hello Feature Flag 1: False
3: 24:39:19 - Hello Feature Flag 1: False
26: 24:39:19 - Hello Feature Flag 1: True
7: 24:39:19 - Hello Feature Flag 1: True
2: 24:39:19 - Hello Feature Flag 1: True
27: 24:39:19 - Hello Feature Flag 1: True
35: 24:39:19 - Hello Feature Flag 1: True
33: 24:39:19 - Hello Feature Flag 1: True
12: 24:39:19 - Hello Feature Flag 1: True
10: 24:39:19 - Hello Feature Flag 1: True
6: 24:39:19 - Hello Feature Flag 1: True
18: 24:39:19 - Hello Feature Flag 1: True
46: 24:39:20 - Hello Feature Flag 1: False
29: 24:39:20 - Hello Feature Flag 1: False
32: 24:39:20 - Hello Feature Flag 1: False
13: 24:39:20 - Hello Feature Flag 1: False
20: 24:39:20 - Hello Feature Flag 1: False
37: 24:39:20 - Hello Feature Flag 1: False
34: 24:39:20 - Hello Feature Flag 1: False
14: 24:39:20 - Hello Feature Flag 1: False
31: 24:39:20 - Hello Feature Flag 1: False
5: 24:39:20 - Hello Feature Flag 1: False
11: 24:39:20 - Hello Feature Flag 1: True
1: 24:39:20 - Hello Feature Flag 1: True
16: 24:39:20 - Hello Feature Flag 1: True
41: 24:39:20 - Hello Feature Flag 1: True
28: 24:39:20 - Hello Feature Flag 1: True
42: 24:39:20 - Hello Feature Flag 1: True
49: 24:39:20 - Hello Feature Flag 1: True
9: 24:39:20 - Hello Feature Flag 1: True
56: 24:39:20 - Hello Feature Flag 1: True
40: 24:39:20 - Hello Feature Flag 1: True
0: 24:39:21 - Hello Feature Flag 1: False
17: 24:39:21 - Hello Feature Flag 1: False
44: 24:39:21 - Hello Feature Flag 1: False
48: 24:39:21 - Hello Feature Flag 1: False
50: 24:39:21 - Hello Feature Flag 1: False
53: 24:39:21 - Hello Feature Flag 1: False
52: 24:39:21 - Hello Feature Flag 1: False
21: 24:39:21 - Hello Feature Flag 1: False
8: 24:39:21 - Hello Feature Flag 1: False
57: 24:39:21 - Hello Feature Flag 1: False
36: 24:39:21 - Hello Feature Flag 1: True
39: 24:39:21 - Hello Feature Flag 1: True
38: 24:39:21 - Hello Feature Flag 1: True
47: 24:39:21 - Hello Feature Flag 1: True
54: 24:39:21 - Hello Feature Flag 1: True
82: 24:39:21 - Hello Feature Flag 1: True
58: 24:39:21 - Hello Feature Flag 1: True
45: 24:39:21 - Hello Feature Flag 1: True
51: 24:39:21 - Hello Feature Flag 1: True
64: 24:39:21 - Hello Feature Flag 1: True
78: 24:39:22 - Hello Feature Flag 1: False
92: 24:39:22 - Hello Feature Flag 1: False
60: 24:39:22 - Hello Feature Flag 1: False
81: 24:39:22 - Hello Feature Flag 1: False
61: 24:39:22 - Hello Feature Flag 1: False
95: 24:39:22 - Hello Feature Flag 1: False
55: 24:39:22 - Hello Feature Flag 1: False
71: 24:39:22 - Hello Feature Flag 1: False
94: 24:39:22 - Hello Feature Flag 1: False
70: 24:39:22 - Hello Feature Flag 1: False
74: 24:39:22 - Hello Feature Flag 1: True
67: 24:39:22 - Hello Feature Flag 1: True
83: 24:39:22 - Hello Feature Flag 1: True
85: 24:39:22 - Hello Feature Flag 1: True
62: 24:39:22 - Hello Feature Flag 1: True
69: 24:39:22 - Hello Feature Flag 1: True
97: 24:39:22 - Hello Feature Flag 1: True
86: 24:39:22 - Hello Feature Flag 1: True
72: 24:39:22 - Hello Feature Flag 1: True
76: 24:39:22 - Hello Feature Flag 1: True
99: 24:39:23 - Hello Feature Flag 1: False
96: 24:39:23 - Hello Feature Flag 1: False
59: 24:39:23 - Hello Feature Flag 1: False
89: 24:39:23 - Hello Feature Flag 1: False
90: 24:39:23 - Hello Feature Flag 1: False
87: 24:39:23 - Hello Feature Flag 1: True
66: 24:39:23 - Hello Feature Flag 1: False
88: 24:39:23 - Hello Feature Flag 1: False
68: 24:39:23 - Hello Feature Flag 1: False
80: 24:39:23 - Hello Feature Flag 1: True
77: 24:39:23 - Hello Feature Flag 1: True
98: 24:39:23 - Hello Feature Flag 1: False
84: 24:39:23 - Hello Feature Flag 1: True
75: 24:39:23 - Hello Feature Flag 1: True
91: 24:39:23 - Hello Feature Flag 1: True
100: 24:39:23 - Hello Feature Flag 1: False
73: 24:39:23 - Hello Feature Flag 1: True
93: 24:39:23 - Hello Feature Flag 1: True
65: 24:39:24 - Hello Feature Flag 1: False
79: 24:39:24 - Hello Feature Flag 1: False
63: 24:39:24 - Hello Feature Flag 1: False
```

> Note: Deleting revisions is a bit of a process. To delete a revision:
> - untag it
> - point all traffic to a remaining revision
> - untag it
> - then delete it
>
> For example:
> - kn service update --traffic hello-stls-ff1f=100
> - kn service update hello-stls --untag ff1t
> - kn revision delete hello-stls-ff1t
> - To remove all unreferenced revisions:
>   - per-service: kn revision delete --prune svc-name
>   - all services in a namespace: kn revision delete --prune-all

### Step 6 - Cleanup

Let's delete the Knative Service. This will delete all revisions and other associated resources.

```shell
kn service delete hello-stls
```
```text
Service 'hello-stls' successfully deleted in namespace 'default'.
```

```shell
kn service list
```
```text
No services found.
```

```shell
kn revision list
```
```text
No revisions found.
```

## Coming Up

Whew! Knative Serving is very powerful... and we just scrateched the surface.

Next, we move onto Knative Eventing in Lab 5.
