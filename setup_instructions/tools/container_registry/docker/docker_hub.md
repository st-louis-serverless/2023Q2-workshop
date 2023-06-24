# Docker Container Registry

If you'd rather use [Docker Hub](https://hub.docker.com) as your container registry instead of GitHub, 
you have two choices:

1. Store images in a public repo
2. Store images in a private repo

## Docker Hub public images

By default, Kubernetes pulls images from Docker hub public repositories. There's no K8s Secret to create and manage.
This is by far the simplest option, but probably not one your organization wants to use.

## Docker Hub private images

For Kubernetes to pull an image from a private Docker repo, you'll need to register Docker Hub credentials 
as a Kubernetes Secret. We'll use the `kubectl` command to do so,  

Full instructions for creating the Secret are here: 
[Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

The summary is this:

1. Login to Docker using the CLI*

> Note: To login to Docker with MFA enabled, you'll need to use a Personal Access Token in place of your password.
> I recommend you create two, one for K8s and one for managing images with the Docker CLI. The K8s one only needs to 
> be Read-Only so Kubernetes can pulling images during deployment. The second one should have Read/Write/Delete 
> privileges so you can push, pull, and delete an image from Docker Hub.  

2. Inspect the Docker config.json file. On the Mac, execute `cat ~/.docker/config.json`

If Docker is using a credential store (e.g. osxkeychain), the output will look like this:
```text
{
	"auths": {
		"https://index.docker.io/v1/": {}
	},
	"credsStore": "osxkeychain"
}
```

In this case, create a secret we'll name `regcred` manually using the command:
```shell
kubectl create secret docker-registry regcred \ 
--docker-server=<your-registry-server> \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email>
```

If the credentials are in the `~/.docker/config.json`, you can create the secret using this file with this command: 
```shell
kubectl create secret generic regcred \
--from-file=.dockerconfigjson=<path/to/.docker/config.json> \
--type=kubernetes.io/dockerconfigjson
```

3. After creating the secret, verify it with:

```shell
kubectl get secret regcred --output=yaml
```

If the credentials were stored in the config.json file, they'll be base64 encoded. Use this command to decode them:
```shell
kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
```

4. With the secret set, you can use the secret when pull the image from your Docker Hub private repo; e.g.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred
```
