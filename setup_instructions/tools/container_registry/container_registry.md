# Container Registry

The term `Container Registry` is a bit of a misnomer as we don't actually register containers. 
What we actually register are the container _images_. Unfortunately, the time to change 
the name has long passed, so you'll hear me say both `image registry` and `container registry`.

In this workshop, we'll default to using the GitHub registry as GitHub and GitHub Actions are commonly used
by many organizations. However, Docker Hub remains a very popular image registry, so feel free to use that if 
you prefer.

Unless you're publishing your images to the public, you'll need to deal with authorization by Kubernetes 
when pulling images for deployments.
