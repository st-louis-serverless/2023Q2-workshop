# Knative Functions

From the [website](https://knative.dev/docs/functions/)

> Knative Functions provides a simple programming model for using functions on Knative, without requiring in-depth 
> knowledge of Knative, Kubernetes, containers, or dockerfiles.
>
> Knative Functions enables you to easily create, build, and deploy stateless, event-driven functions as Knative 
> Services by using the func CLI.
> 
> When you build or run a function, an Open Container Initiative (OCI) format container image is generated 
> automatically for you, and is stored in a container registry. Each time you update your code and then run or 
> deploy it, the container image is also updated.
> 
> You can create functions and manage function workflows by using the func CLI, or by using the kn func plugin for 
> the Knative CLI.

If you think of Knative as your serverless cloud in Kubernetes, you can think of Knative Functions as like AWS Lambdas. 
You write the business logic as functions, and Kn Functions takes care of building, deployment, and management 
into your serverless cloud.

In this lab, we'll explore some simple Kn Functions just to show off the capabilities.

> Prerequisites:
> - Make sure Lab 2 is complete. This created a kind cluster with k3d and installed Knative
> - Make sure you've installed the `func` cli and `kn func` plugin.  
> See [kn_tools](../../setup_instructions/tools/kn_tools.md)
> - You have a Docker account, or an account at another container registry like GitHub, Google, AWS, Quay, etc.

In the way that a Git repository tracks revisions for a project, a container registry repository stores versions 
(tags) for a container image. Docker still allows free personal accounts with unlimited public repositories, and 
this is what I will use in this workshop, though we will discuss how to use a private repository later.

## Lab Steps

### Step 1 - Explore available `func` commands

Run this command:
```shell
func --help
```
```text
func is the command line interface for managing Knative Function resources

        Create a new Node.js function in the current directory:
        func create --language node myfunction

        Deploy the function using Docker hub to host the image:
        func deploy --registry docker.io/alice

Learn more about Functions:  https://knative.dev/docs/functions/
Learn more about Knative at: https://knative.dev

Primary Commands:
  create      Create a function
  describe    Describe a function
  deploy      Deploy a function
  delete      Undeploy a function
  list        List deployed functions

Development Commands:
  run         Run the function locally
  invoke      Invoke a local or remote function
  build       Build a function container

System Commands:
  config      Configure a function
  languages   List available function language runtimes
  templates   List available function source templates
  repository  Manage installed template repositories

Other Commands:
  completion  Output functions shell completion code
  version     Function client version information

Use "func <command> --help" for more information about a given command.
```

The Knative cli command is `kn`. If you installed the `func` cli and the Knative func plugin,
you can either execute the commands as `func <command>` or `kn func <command>`. The results will be the same.

To see that `kn func` yields the same, run:
```shell
kn func --help
```

### Step 2 - Language Packs and Templates

#### Language Packs

From the [docs](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md):
> Language Packs is the mechanism by which the Knative Functions binary can be extended to support additional 
> runtimes, function signatures, even operating systems and installed tooling for a Function. Language 
> Packs are typically distributed via Git repositories but may also simply exist as a directory on a disc.

> Knative Function Language Packs are meant to drastically reduce the code required for developers to be 
> productive on Knative, and in concert with the func CLI make deploying event driven, container-based 
> Knative Services simple and straightforward. Language Packs and the func CLI streamline a Knative 
> developer's experience by eliminating or reducing developer tasks that are not directly related to solving 
> their business problems.

To list the language packs that come out-of-the-box with Knative Functions:
```shell
func languages
```
```text
go
node
python
quarkus
rust
springboot
typescript
```

#### Code Generation Templates

```shell
func templates
```
```text
LANGUAGE     TEMPLATE
go           cloudevents
go           http
node         cloudevents
node         http
python       cloudevents
python       flask
python       http
python       wsgi
quarkus      cloudevents
quarkus      http
rust         cloudevents
rust         http
springboot   cloudevents
springboot   http
typescript   cloudevents
typescript   http
```

Notice that for all but python, there are two flavors of templates, `http` and `cloudevents`. 
Exactly what the template does with these depends on the language and template implementation.

For example, the `node` language pack [http template](https://github.com/knative/func/tree/main/templates/node/http) 
is about receiving HTTP GET and POST requests. It exposes three endpoints: `/`, `/health/readiness`, 
and `/health/liveness`. The `index.js` handler gets a `Context` object that looks like this:

```javascript
function handleRequest(context) {
  const log = context.log;
  log.info(context.httpVersion);
  log.info(context.method); // the HTTP request method (only GET or POST supported)
  log.info(context.query); // if query parameters are provided in a GET request
  log.info(context.body); // contains the request body for a POST request
  log.info(context.headers); // all HTTP headers sent with the event
}
```
In contrast, the `node` [cloudevents template](https://github.com/knative/func/tree/main/templates/node/cloudevents) 
generates code that handles CloudEvents.

In the rest of this lab, we'll make a Node function for HTTP requests and deploy it into our cluster.

### Step 3 - Create a Node HTTP Function

> If not executing from markdown, change to directory `labs/lab3`

```shell
func create -l node -t http functions/node/hello-http 
```
```text
Created node function in /Users/jackfrosch/.../labs/lab3/functions/node/hello-http
```

#### Review the created output

```shell
tree -a functions/node/hello-http
```
(To install tree, run `brew install tree`)
```text
.
├── .func
├── .gitignore
├── README.md
├── func.yaml
├── index.js
├── package-lock.json
├── package.json
└── test
    ├── integration.js
    └── unit.js
```

#### Review the [func.yaml](functions/node/hello-http/func.yaml) captured here:
```text
specVersion: 0.35.0
name: hello-http
runtime: node
registry: ""
image: ""
created: 2023-07-08T14:16:18.803463-05:00
build:
  pvcSize: 256Mi
```

#### Review the created function's [README.md](functions/node/hello-http/README.md).

#### Review the [index.js](functions/node/hello-http/index.js)

### Step 4 - Run the function locally

First, run
```shell
docker ps
```
```text
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                                NAMES
74bedb122e9a   registry:2             "/entrypoint.sh /etc…"   4 minutes ago    Up 4 minutes    127.0.0.1:5001->5000/tcp                             kind-registry
e4e8120c3b66   kindest/node:v1.25.3   "/usr/local/bin/entr…"   19 minutes ago   Up 19 minutes   127.0.0.1:51351->6443/tcp, 127.0.0.1:80->31080/tcp   knative-control-plane
```

Now, we'll run our function.

> Note: By default the function will be built if never built, or if changes are detected. The build takes a bit
> of time, so be prepared to wait a bit.

```shell
func run --build --path functions/node/hello-http --registry localhost:5001
```
After what seems like a long time, 
```text
   🙌 Function image built: localhost:5001/hello-http/hello-http:latest
Function started on port 8080
{"level":30,"time":1688962702804,"pid":40,"hostname":"d9392f991dd1","node_version":"v18.16.1","msg":"Server listening at http://[::]:8080"}
```

Notice the `msg` field in that last line: `Server listening at http://[::]:8080`.

This means we can send an http request into the function at localhost:8080. Let's try it with a GET:
```shell
curl -s "localhost:8080?message=Hello%20St.%20Louis%20Serverless" | jq
```
```text
{
  "query": {
    "message": "Hello St. Louis Serverless"
  }
}
```

Test it with a POST:
```shell
curl -s -X POST "localhost:8080" -H'Content-type: application/json' -d '{"orderId": 1234, "customer": "Acme, Inc."}' | jq
```
```text
{
  "orderId": 1234,
  "customer": "Acme, Inc."
}
```

Let's check docker:
```shell
docker ps
```
```text
CONTAINER ID   IMAGE                             COMMAND                  CREATED          STATUS          PORTS                                                NAMES
cd83015b2e55   localhost:5001/hello-http:latest  "/cnb/process/web"       39 seconds ago   Up 38 seconds   127.0.0.1:8080->8080/tcp                             sleepy_brown
74bedb122e9a   registry:2                        "/entrypoint.sh /etc…"   33 minutes ago   Up 2 minutes    127.0.0.1:5001->5000/tcp                             kind-registry
e4e8120c3b66   kindest/node:v1.25.3              "/usr/local/bin/entr…"   48 minutes ago   Up 48 minutes   127.0.0.1:51351->6443/tcp, 127.0.0.1:80->31080/tcp   knative-control-plane
```

Let's stop it:

```shell
docker stop sleepy_brown
```

Let's tag it:
```shell
docker tag localhost:5001/hello-http:latest localhost:5001/hello-http:1.0
```

### Step 6 - Deploy it

We see it's working and in our local Docker repo. (It's not yet pushed to Docker Hub though.)

Let's rebuild and deploy it with a tag.

```shell
func deploy --image localhost:5001/hello-http:1.0 --path functions/node/hello-http
```
```text
⬆️  Deploying function to the cluster
W0709 23:29:30.741497   74864 warnings.go:70] Kubernetes default value is insecure, Knative may default this to secure in a future release: spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation, spec.template.spec.containers[0].securityContext.cap
   ✅ Function updated in namespace "default" and exposed at URL: 
   http://hello-http.default.127.0.0.1.sslip.io   
```

> Note that url, http://hello-http.default.127.0.0.1.sslip.io, is public

### Step 7 - Invoke it on the cluster

First, GET with the public url:
```shell
curl -s "http://hello-http.default.127.0.0.1.sslip.io?message=Hello%20St.%20Louis%20Serverless" | jq
```
```text
{
  "query": {
    "message": "Hello St. Louis Serverless"
  }
}
```

Test it with a POST:
```shell
curl -s -X POST "http://hello-http.default.127.0.0.1.sslip.io" -H'Content-type: application/json' -d '{"orderId": 1234, "customer": "Acme, Inc."}' | jq
```
```text
{
  "orderId": 1234,
  "customer": "Acme, Inc."
}
```

We can also use the `func invoke` to invoke the function via its `private`, in-cluster url: 
```shell
func invoke --format=http \
--target http://hello-http.default.svc.cluster.local \
--path functions/node/hello-http \
--data='{"orderId": 1234, "customer": "Acme, Inc."}'
```
```text
Received response
{"orderId":1234,"customer":"Acme, Inc."}
```

The `func invoke` seems to be quite slow for reasons that aren't clear.

```shell
kubectl apply -f domain-mapping.yaml
```

### Step 8 - Clean up

Delete the Knative Function from the cluster (but the image stays on the repo):

```shell
func delete hello-http
```
```text
🕓 Removing Knative Service 'hello-http' and all dependent resources
```

## Coming Up

Lab 3 illustrated the very simple create / code / test / deploy model offered by Knative Functions. In Lab 4, we'll 
dive into Knative Serving and explore the various deployment and traffic splitting options.
