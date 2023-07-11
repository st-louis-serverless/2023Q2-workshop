## Docker

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

> My View: Docker threw away a lot of its good will in a bone-headed licensing change that imposed
> significant costs to enterprises where before there was none. Large companies can easily afford
> the modest $5/month/developer fee, but being force-fed this change proved too much for many.

Fortunately, if you're in a company that walked away from Docker the company, there are many good
alternatives.

### Installing a container runtime

Since we'll be running `KinD` (Kubernetes in Docker), you need something that can run "docker" containers. You 
may want to explore these (or others):

- [Docker Desktop](https://docker.com) <==== This is the one I'll be using
- [Rancher Desktop](https://rancherdesktop.io/)
- [podman](https://podman.io/)
- [Nerdctl](https://github.com/containerd/nerdctl)

I like Rancher Desktop, but in this workshop I will be using Docker Desktop.

> Tip: I experienced a lot of problems running podman on a Mac M1 when using TestContainers. I had no
> troubles with Rancher Desktop or Docker Desktop. Unfair as it is, this soured me completely on using podman.
