# Installing Rancher Desktop

[Rancher Desktop](https://rancherdesktop.io) is a Docker Desktop replacement - and much more.

Docker Desktop is a very useful GUI for managing Docker and Docker Compose images and containers. While
it offers support for running a single Kubernetes node of a version they choose, it has pretty limited
Kubernetes support.

In contrast, Rancher Desktop offers container and image management support like Docker Desktop, but it's support for
Kubernetes is far greater.

## Features (gathered from its home page)

### Container Management
Container management to build, push, and pull images and run containers. It uses the same container runtime as 
Kubernetes. Built images are immediately available to use in your local workloads without any pushing, 
pulling, or copying.

### Kubernetes Made Simple
Getting started with Kubernetes on your desktop can be a project. Especially if you want to match the version of 
Kubernetes you run locally to the one you run in production. Rancher Desktop makes it as easy as setting a preference.

### Built On Proven Projects
Rancher Desktop leverages proven projects to do the dirty work. That includes Moby, containerd, k3s, kubectl, and more. 
These projects have demonstrated themselves as trustworthy and provide a foundation you can trust.

### Setting the version of Kubernetes you want to use
Through a simple user interface you can configure how Kubernetes works. That includes:
- Setting the version of Kubernetes you want to use
- Choosing your container runtime
- Configuring the system resources for the virtual machine (on Mac and Linux)
- Resetting Kubernetes or Kubernetes and the container runtime to default with the push of a button

> Note: The de facto standard cli for interacting with Kubernetes is `kubectl` (If you can't or would rather not install Rancher Desktop, you'll need to install `kubectl` manually.  
