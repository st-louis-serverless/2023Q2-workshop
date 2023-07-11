# Kubernetes Workshop Tooling Setup

You may have heard Kubernetes (K8s) is a bit complex to setup, manage, and use. It is, but the right tools 
can take a lot of the pain out of it.    

This workshop is about doing serverless on Kubernetes with Knative. It's not about making you a K8s 
administrator. However, you are going to need a few tools setup for the workshop. Chances are, if 
you're a developer or architect, you may have many or all of these installed already.

What follows is helpful guidance to cut through the noise on installing the tools. 
However, you should consult the formal documentation (links provided) to see the 
full solution.

## Before we begin

Save off any existing .kube config directory. If you've already been working with Kubernetes, 
you will probably have a `~/.kube` folder to avoid conflicts and unnecessary headaches.

For best results in this workshop, please save this off before installing `kind`, Rancher Desktop; e.g.
```shell
mv ~/.kube ~/.kube-save
```

## Tools we'll use

We'll use the following tools in the labs. The optional ones are good to have.

Tools you need:

- [Container Runtime (i.e. docker)](tools/docker.md)
- [Git](tools/git.md)
- [kind](tools/kind.md)
- [Knative cli tools](tools/kn_tools.md) 
- [Node](tools/node.md)

Optional tools you may want to use. (We're working with containers, 
so you don't technically have to have these installed.)
- [Your favorite IDE](tools/ide.md)
- [Typescript](#installing-typescript)

That's not too bad. See you in the workshop!
