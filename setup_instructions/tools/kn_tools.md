# Knative tools

## Knative CLI(kn)

From the website:

> The Knative CLI (kn) provides a quick and easy interface for creating Knative resources, such as Knative Services and Event Sources, without the need to create or modify YAML files directly. 
> 
> The kn CLI also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

To install the Knative CLI, follow the 
[installation instructions](https://knative.dev/docs/getting-started/quickstart-install/#before-you-begin).

Mac users can just run:
```shell
brew install knative/client/kn
```

Verify the installation with:
```shell
kn version
```
```text
Version:      v1.10.0
Build Date:   2023-04-26 10:17:21
Git Revision: 46dbf661
Supported APIs:
* Serving
  - serving.knative.dev/v1 (knative-serving v1.10.0)
* Eventing
  - sources.knative.dev/v1 (knative-eventing v1.10.0)
  - eventing.knative.dev/v1 (knative-eventing v1.10.0)
```

## Knative Function CLI (func)

From the website:

> Knative Functions provides a simple programming model for using functions on Knative, 
> without requiring in-depth knowledge of Knative, Kubernetes, containers, or dockerfiles.
>
> Knative Functions enables you to easily create, build, and deploy stateless, 
> event-driven functions as Knative Services by using the func CLI.

To install the Knative Functions CLI, follow the
[installation instructions](https://knative.dev/docs/functions/install-func/).

Mac users can just run these two commands:
```shell
brew install knative/client/kn
```
```shell
brew install func
```

Verify the installation with:
```shell
func version
```
```text
v1.10.0
```

You can use either `func` or `kn func` to run the Knative Function CLI.

## Knative Quickstart Plugin

This provides a streamlined, opinionated way to install Knative into a `kind` or `minikube` cluster.

```shell
brew install knative-sandbox/kn-plugins/quickstart
```

Verify:
```shell
kn quickstart version
```
```text
Version:      v1.10.0
Build Date:   2023-04-26 09:36:18
Git Revision: 4ed8641
```
