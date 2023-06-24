# Kubernetes Workshop Tooling Setup

You may have heard Kubernetes (K8s) is a bit complex to setup, manage, and use. It is, but the right tools 
can take a lot of the pain out of it.    

This workshop is about doing serverless on Kubernetes with Knative. It's not about making you a K8s 
administrator. However, you are going to need a few tools setup for the workshop. Chances are, if 
you're a developer or architect, you may have many or all of these installed already.

What follows is helpful guidance to cut through the noise on installing the tools. 
However, you should consult the formal documentation (links provided) to see the 
full solution.
 
## Tools We'll Use

We'll use the following tools in the labs. The optional ones will be used for 
demonstration

- [Your favorite IDE](tools/ide.md)
- [Git](tools/git.md)
- [Node](#installing-node)
- [Typescript](#installing-typescript)
- [Java (GraalVM JDK)](#installing-java)
- [Rancher Desktop](#installing-rancher-desktop) or [k3d](#installing-k3d)
- [Container Registry](tools/container_registry)
- [Knative cli](tools/knative_cli.md)

## Optional
- k9s (https://k9scli.io/)






### Installing Rancher Desktop

[Rancher Desktop](https://rancherdesktop.io) is a Docker Desktop replacement.

Docker Desktop is a very useful GUI for managing Docker and Docker Compose images and containers. While
it offers support for running a single Kubernetes node of a version they choose, it has pretty limited
Kubernetes support.

In contrast, Rancher Desktop offers container and image management support as well, but it's support for 
Kubernetes is far greater than Docker Desktop.




> Note: If you can't or would rather not install Rancher Desktop,  

#### About Docker

Containers, and its de facto synonym Docker, was a fantastic addition to enterprise computing.

When we say _Docker_, we might really mean any of these things and more:
- A specification for container images (DockerFile)
- A runtime for running images (docker engine running as dockerd daemon)
- A CLI for interacting with the docker engine
- Docker Desktop, a GUI client for interacting with the Docker engine
- The company, [Docker.com](https://docker.com)
- Containers. Images. Networks. More..

[Geekflare Article on Docker Archtecture](https://geekflare.com/docker-architecture/)

Its small application runtime environment proved an essential ingredient for our development,
testing and consistent, reproducible deployments. Without containers, we would never have been
able to achieve the massively, horizontally-scaled applications we have today. Indeed, Kubernetes
was born out of the need to orchestrate dozens to hundreds to thousands of running containers.

The company behind Docker produced a lot of great open source and proprietary tools generating
great loyalty and endearment from developers and organizations.

> Opinion: Docker threw away most of its good will in a bone-headed licensing change that imposed
> significant costs to enterprises where before there was none. Large companies can easily afford
> the modest $5/month/developer fee, but being force-fed what tasted like a bait-and-switch crap
> sandwich proved too much for many.

Fortunately, if you're in a company that walked away from Docker the company, there are many good
alternatives.

### Installing a container runtime

Explore these (or others) and install one or more:

- [Docker Desktop](https://docker.com)
- [Rancher Desktop](https://rancherdesktop.io/)
- [podman](https://podman.io/)
- [Nerdctl](https://github.com/containerd/nerdctl)

I prefer Rancher Desktop, but also use Docker Desktop. Rancher Desktop not only lets you switch between
using the Docker engine and Nerdctl, but also allows you to run different versions of Kubernetes.

> Tip: I experienced a lot of problems running podman on a Mac M1 when using TestContainers. I had no
> troubles with Rancher Desktop or Docker Desktop. Unfair as it is, this soured me completely on using podman.

### Install Pulumi

Prerequisites: npm (from Node)

The CDK Toolkit allows us to run CDK commands from the commandline. 
It can be installed locally or in a CI/CD environment.

See [AWS CDK Toolkit docs](https://docs.aws.amazon.com/cdk/v2/guide/cli.html)

Note from the docs:
> If you regularly work with multiple versions of 
> the AWS CDK, consider installing a matching version of the AWS CDK 
> Toolkit in individual CDK projects. To do this, omit -g from the 
> npm install command. Then use npx aws-cdk to invoke it. This runs 
> the local version if one exists, falling back to a global version if not.

Global Installation
```shell
npm install -g aws-cdk
```
Verify installation
```shell
cdk --version
```
```text
2.62.2 (build c164a49)
```

### AWS CLI
AWS provides a useful Command Line Interface (CLI) for interacting with your AWS account and resources.

[AWS official instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Summary:

#### Mac users (install just for current user)

- In your browser, download the macOS pkg file: https://awscli.amazonaws.com/AWSCLIV2.pkg
- Create symlinks

```shell
sudo ln -s /folder/installed/aws-cli/aws /usr/local/bin/aws
sudo ln -s /folder/installed/aws-cli/aws_completer /usr/local/bin/aws_completer
```

- Verify
```shell
which aws
aws --version
```
```text
aws-cli/2.10.3 Python/3.9.11 Darwin/22.3.0 exe/x86_64 prompt/off
```

#### Windows users

Install via MSI: https://awscli.amazonaws.com/AWSCLIV2.msi, or command line:
```shell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

Verify:
```shell
aws --version
```
```text
aws-cli/2.10.0 Python/3.11.2 Windows/10 exe/AMD64 prompt/off
```

### Linux users

```shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Uninstalling instructions: https://docs.aws.amazon.com/cli/latest/userguide/uninstall.html.

### Installing Java

This workshop will primarily use TypeScript. However, Java is ubiquitous. For many use cases, Java has better 
performance than Node, so we'll also use it in this workshops as an _**optional**_ approach.

A Google search on `installing java` will reveal there are many ways to
install Java. Once an approach is chosen, you need to decide which
Java Development Kit (JDK) you will use.

Since this is a workshop is focused on serverless on Kubernetes, we'll use a **Graalvm JDK**. GraalVM gives us a JDK 
for use in development that's based on OpenJDK. It also offers Ahead of Time (AOT) compilation to a small executable 
binary, perfect for our serverless architecture.

Windows users should follow the [GraalVM instructions](https://www.graalvm.org/latest/docs/getting-started/windows/).
or can use a community package from [Chocalatey](https://community.chocolatey.org/packages/graalvm).

I strongly recommend Mac and Linux users use [SDK Man](https://sdkman.io/).

### sdkman
To install sdkman, run
```shell
curl -s "https://get.sdkman.io" | bash
```

Verify with
```shell
sdk version
```
```text
script: 5.18.1
native: 0.1.3
```

To list available Java versions and JDK distributions:
```shell
sdk list java
```
```text
================================================================================
Available Java Versions for macOS 64bit
================================================================================
 Vendor        | Use | Version      | Dist    | Status     | Identifier
--------------------------------------------------------------------------------
 Corretto      |     | 20           | amzn    |            | 20-amzn             
               |     | 20.0.1       | amzn    |            | 20.0.1-amzn         
               |     | 19.0.2       | amzn    |            | 19.0.2-amzn         
               |     | 19.0.1       | amzn    |            | 19.0.1-amzn         
               |     | 17.0.7       | amzn    |            | 17.0.7-amzn         
               |     | 17.0.6       | amzn    | installed  | 17.0.6-amzn         
               |     | 17.0.5       | amzn    |            | 17.0.5-amzn
...                       
 Gluon         |     | 22.1.0.1.r17 | gln     |            | 22.1.0.1.r17-gln    
               |     | 22.1.0.1.r11 | gln     |            | 22.1.0.1.r11-gln    
               |     | 22.0.0.3.r17 | gln     |            | 22.0.0.3.r17-gln    
               |     | 22.0.0.3.r11 | gln     |            | 22.0.0.3.r11-gln    
 GraalVM       |     | 22.3.r19     | grl     |            | 22.3.r19-grl        
               |     | 22.3.r17     | grl     |            | 22.3.r17-grl        
               |     | 22.3.r11     | grl     |            | 22.3.r11-grl 
...               
```
> Note: You may need to source your shell config file

Install GraalVM for Java 17:
```shell
sdk install java 22.3.r17-grl
```
```text
Downloading: java 22.3.r17-grl

In progress...

##################################################### 100.0%

Repackaging Java 22.3.r17-grl...

Done repackaging...
Cleaning up residual files...

Installing: java 22.3.r17-grl
Done installing!

Do you want java 22.3.r17-grl to be set as default? (Y/n): y

Setting java 22.3.r17-grl as default.
```

Verify Java installed:
```shell
java --version
```
```text
openjdk version "17.0.5" 2022-10-18
OpenJDK Runtime Environment GraalVM CE 22.3.0 (build 17.0.5+8-jvmci-22.3-b08)
OpenJDK 64-Bit Server VM GraalVM CE 22.3.0 (build 17.0.5+8-jvmci-22.3-b08, mixed mode, sharing)
```

### Installing k3d

[K3d](https://k3d.io/) is really two docker image

## Optional Tools
- doctl
- aws-cli
- Pulumi (https://www.pulumi.com/)

### Digital Ocean CLI

After working with Kubernetes and Knative locally, we'll deploy our work to a couple of public cloud providers. The 
first will be Digital Ocean. If you want to follow along, you'll want to install the Digital Ocean CLI.

### AWS CLI

After working with Kubernetes and Knative locally, we'll deploy our work to a couple of public cloud providers. The
first will be Digital Ocean. If you want to follow along, you'll want to install the Digital Ocean CLI.

## Whew!

That may seem like a lot if you're starting from scratch... but you probably aren't.

Onto the labs!
