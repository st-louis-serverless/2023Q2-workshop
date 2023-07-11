# Our first custom service

- Build a Docker image
- Test it standalone
- Deploy it as a Knative *service*
- Verify service is present and avaiable
- Hit the endpoint to see what happens
- Delete service

### Build the Docker image

```shell
% docker build . -t jackfrosch/hello-stls
```
> Notes
>> 1: Image will automatically get tag "latest" \
>> 2: The dev.local repo name tells KN to skip verifying digest SHA which isn't present on local images 

### Test it standalone 
For manual testing, it's convenient to run a local Docker image in a container
```shell
% docker run -p 8180:8080 --env TARGET=World dev.local/hello-stls
```
             
### Deploy it as a Knative service

Let's deploy this image to Knative using the Knative CLI

Since we're using a local image, we'll use a YAML config because we need to specify imagePullPolicy: Never
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-stls
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: dev.local/hello-stls:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World"
```

Before deploying and testing the service, let's watch the pods running in the `default` namespace:
```shell
% kc get pods -n default
NAME                                READY   STATUS    RESTARTS   AGE
knative-operator-6c449969f6-drt2j   1/1     Running   0          19m
```

Open a new terminal window and deploy the service using Knative CLI:
```shell
% kn service create hello-stls --filename hello-stls.yaml
Creating service 'hello-stls' in namespace 'default':

  0.074s The Route is still working to reflect the latest desired specification.
  0.142s Configuration "hello-stls" is waiting for a Revision to become ready.
  3.709s ...
  3.752s Ingress has not yet been reconciled.
  3.856s Waiting for load balancer to be ready
  4.001s Ready to serve.

Service 'hello-stls' created to latest revision 'hello-stls-00001' is available at URL:
http://hello-stls.default.example.com
```

### Verify it was deployed and is available

Verify the service is available
```shell
% kc get pods -n default
NAME         URL                                     LATEST             AGE   CONDITIONS   READY   REASON
hello-stls   http://hello-stls.default.example.com   hello-stls-00001   10s   3 OK / 3     True
```

Check the pods again:
```shell
% kc get pods                                            
NAME                                          READY   STATUS    RESTARTS   AGE
knative-operator-6c449969f6-dbg74             1/1     Running   0          48m
hello-stls-00001-deployment-d767f5c4b-d9hcc   2/2     Running   0          12s
```

Let's test the endpoint using curl:
```shell
% curl http://hello-stls.default.example.com
Hello STLS!
```

Dig into the details of the pod:
```shell
% kc describe pod hello-stls-00001-deployment-d767f5c4b-d9hcc
Name:                      hello-stls-00001-deployment-d767f5c4b-d9hcc
Namespace:                 default
Priority:                  0
Node:                      lima-rancher-desktop/192.168.205.2
Start Time:                Thu, 31 Mar 2022 10:33:02 -0500
Labels:                    app=hello-stls-00001
                           pod-template-hash=d767f5c4b
                           serving.knative.dev/configuration=hello-stls
                           serving.knative.dev/configurationGeneration=1
                           serving.knative.dev/configurationUID=8b38074d-fbce-43b8-8195-0b2b4abbb55f
                           serving.knative.dev/revision=hello-stls-00001
                           serving.knative.dev/revisionUID=cd95168a-349c-4fdf-9975-17b189708ce5
                           serving.knative.dev/service=hello-stls
                           serving.knative.dev/serviceUID=69ddca15-ec64-435a-96d1-253d98d2a720
Annotations:               autoscaling.knative.dev/maxScale: 10
                           autoscaling.knative.dev/minScale: 0
                           client.knative.dev/updateTimestamp: 2022-03-31T15:33:01Z
                           serving.knative.dev/creator: system:admin
Status:                    Terminating (lasts <invalid>)
Termination Grace Period:  300s
IP:                        172.17.0.24
IPs:
  IP:           172.17.0.24
Controlled By:  ReplicaSet/hello-stls-00001-deployment-d767f5c4b
Containers:
  user-container:
    Container ID:   docker://114822da7e8de8acdf51ce7e7483d018132fa4a41f31a0b932dbe5fe5ccef7a6
    Image:          dev.local/hello-stls:latest
    Image ID:       docker://sha256:98104405b5de91b569128952773535130120f9d1c89e76fadb09a7fd26e4ded6
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Thu, 31 Mar 2022 10:33:03 -0500
    Ready:          True
    Restart Count:  0
    Environment:
      TARGET:           World
      PORT:             8080
      K_REVISION:       hello-stls-00001
      K_CONFIGURATION:  hello-stls
      K_SERVICE:        hello-stls
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-w5rmt (ro)
  queue-proxy:
    Container ID:   docker://dee5586eea8a6b3200aaf51c449ad0bc9a55952eed85fefa4536ef9424a99a2c
    Image:          gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:96977f1a6618e3aa6c6a4ee421da2d3693794f9bd18be3b057a802830e0b9180
    Image ID:       docker-pullable://gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:96977f1a6618e3aa6c6a4ee421da2d3693794f9bd18be3b057a802830e0b9180
    Ports:          8022/TCP, 9090/TCP, 9091/TCP, 8012/TCP
    Host Ports:     0/TCP, 0/TCP, 0/TCP, 0/TCP
    State:          Running
      Started:      Thu, 31 Mar 2022 10:33:04 -0500
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:      25m
    Readiness:  http-get http://:8012/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      SERVING_NAMESPACE:                 default
      SERVING_SERVICE:                   hello-stls
      SERVING_CONFIGURATION:             hello-stls
      SERVING_REVISION:                  hello-stls-00001
      QUEUE_SERVING_PORT:                8012
      CONTAINER_CONCURRENCY:             1
      REVISION_TIMEOUT_SECONDS:          300
      MAX_DURATION_SECONDS:              0
      SERVING_POD:                       hello-stls-00001-deployment-d767f5c4b-d9hcc (v1:metadata.name)
      SERVING_POD_IP:                     (v1:status.podIP)
      SERVING_LOGGING_CONFIG:            
      SERVING_LOGGING_LEVEL:             
      SERVING_REQUEST_LOG_TEMPLATE:      {"httpRequest": {"requestMethod": "{{.Request.Method}}", "requestUrl": "{{js .Request.RequestURI}}", "requestSize": "{{.Request.ContentLength}}", "status": {{.Response.Code}}, "responseSize": "{{.Response.Size}}", "userAgent": "{{js .Request.UserAgent}}", "remoteIp": "{{js .Request.RemoteAddr}}", "serverIp": "{{.Revision.PodIP}}", "referer": "{{js .Request.Referer}}", "latency": "{{.Response.Latency}}s", "protocol": "{{.Request.Proto}}"}, "traceId": "{{index .Request.Header "X-B3-Traceid"}}"}
      SERVING_ENABLE_REQUEST_LOG:        false
      SERVING_REQUEST_METRICS_BACKEND:   prometheus
      TRACING_CONFIG_BACKEND:            none
      TRACING_CONFIG_ZIPKIN_ENDPOINT:    
      TRACING_CONFIG_DEBUG:              false
      TRACING_CONFIG_SAMPLE_RATE:        0.1
      USER_PORT:                         8080
      SYSTEM_NAMESPACE:                  knative-serving
      METRICS_DOMAIN:                    knative.dev/internal/serving
      SERVING_READINESS_PROBE:           {"tcpSocket":{"port":8080,"host":"127.0.0.1"},"successThreshold":1}
      ENABLE_PROFILING:                  false
      SERVING_ENABLE_PROBE_REQUEST_LOG:  false
      METRICS_COLLECTOR_ADDRESS:         
      CONCURRENCY_STATE_ENDPOINT:        
      CONCURRENCY_STATE_TOKEN_PATH:      /var/run/secrets/tokens/state-token
      HOST_IP:                            (v1:status.hostIP)
      ENABLE_HTTP2_AUTO_DETECTION:       false
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-w5rmt (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-w5rmt:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  83s   default-scheduler  Successfully assigned default/hello-stls-00001-deployment-d767f5c4b-d9hcc to lima-rancher-desktop
  Normal  Pulled     82s   kubelet            Container image "dev.local/hello-stls:latest" already present on machine
  Normal  Created    82s   kubelet            Created container user-container
  Normal  Started    82s   kubelet            Started container user-container
  Normal  Pulled     82s   kubelet            Container image "gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:96977f1a6618e3aa6c6a4ee421da2d3693794f9bd18be3b057a802830e0b9180" already present on machine
  Normal  Created    82s   kubelet            Created container queue-proxy
  Normal  Started    81s   kubelet            Started container queue-proxy
  Normal  Killing    21s   kubelet            Stopping container user-container
  Normal  Killing    21s   kubelet            Stopping container queue-proxy
```

### 

### Delete the service
```shell
kn service delete hello-stls
```
