# Lab5 - Knative Eventing

Knative Eventing allows us to move from synchronous processing to asynchronous, event-driven processing.

In AWS terms, Knative Eventing is a bit like EventBridge, except the event messages follow an industry-standard 
[CloudEvents](https://cloudevents.io) specification.

For this lab, we're going to use a nifty web-based demonstrator from `ruromero/cloudevents-player` 
to illustrate Knative Eventing.

## Steps

### Step 1 - Initial state

```shell
kn service list && kn broker list && kn trigger list && kn service list
```
```text
No services found.
NAME             URL                                                                               AGE     CONDITIONS   READY   REASON
example-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker   7h55m   6 OK / 6     True    
No triggers found.
No services found.
```

We'll delete that example-broker to start fresh:
```shell
kn broker delete example-broker
```
```text
Broker 'example-broker' successfully deleted in namespace 'default'.
```

```shell
kn service list && kn broker list && kn trigger list && kn service list
```
```text
No services found.
No brokers found.
No triggers found.
No services found.
```

### Step 2 - Create stls broker and service

```shell
kn broker create stls-broker
```
```text
Broker 'stls-broker' successfully created in namespace 'default'.
```

```shell
kn service create eventing-demo --image ruromero/cloudevents-player:latest \
--env BROKER_URL=http://broker-ingress.knative-eventing.svc.cluster.local/default/stls-broker
```
```text
Warning: ...
Creating service 'eventing-demo' in namespace 'default':

  0.015s The Route is still working to reflect the latest desired specification.
  0.021s ...
  0.035s Configuration "eventing-demo" is waiting for a Revision to become ready.
  5.628s ...
  5.642s Ingress has not yet been reconciled.
  5.665s Waiting for load balancer to be ready
  5.852s Ready to serve.

Service 'eventing-demo' created to latest revision 'eventing-demo-00001' is available at URL:
http://eventing-demo.default.127.0.0.1.sslip.io
```

```shell
kn service list
```
```text
NAME            URL                                               LATEST                AGE   CONDITIONS   READY   REASON
eventing-demo   http://eventing-demo.default.127.0.0.1.sslip.io   eventing-demo-00001   48s   3 OK / 3     True
```

### Step 3 - Run the Event Player

If we visit that URL, we'll get a [Event Player](event_player.png) web page displayed. Fill in values like:
- Event ID : 1
- Event Type: stls.foo
- Event Source: stls
- Spec Version: leave as 1.0
- Message: { "message": "stls!" }

Then click on `Send Event`.

The event is sent, but there's no Subscriber to receive it. Let's fix that.

### Step 4 - Create a Trigger

First click, `Clear Events` to start fresh.

A Trigger defines the rules needed to route the event.

The Event Player acts as booth a Producer and Subscriber, so we'll set up a Trigger to router `foo` and `bar` events.

```shell
kn trigger create foo-trigger --broker stls-broker --filter type=stls.foo --sink eventing-demo
```
```text
Trigger 'foo-trigger' successfully created in namespace 'default'.
```

```shell
kn trigger create bar-trigger --broker stls-broker --filter type=stls.bar --sink eventing-demo
```
```text
Trigger 'bar-trigger' successfully created in namespace 'default'.
```

```shell
kn trigger list
```
```text
NAME          BROKER        SINK                 AGE     CONDITIONS   READY       REASON
bar-trigger   stls-broker   ksvc:eventing-demo   14s     0 OK / 0     <unknown>   <unknown>
foo-trigger   stls-broker   ksvc:eventing-demo   3m27s   0 OK / 0     <unknown>   <unknown>
```

```text
Trigger 'foo-trigger' successfully created in namespace 'default'.
```

Now enter:
- Event ID : 1
- Event Type: stls.foo
- Event Source: stls
- Spec Version: leave as 1.0
- Message: { "message": "stls!" }

and click `Send Event`. Now, you'll see the event was both [sent and received](event_sent_and_received.png).

If you're curious about the payloads, click the `Envelope` icon.  The events looks like this:
```json
{
  "root": {
    "attributes": {
      "datacontenttype": "application/json",
      "id": "1",
      "mediaType": "application/json",
      "source": "stls",
      "specversion": "1.0",
      "type": "stls.foo"
    },
    "data": {
      "message": "Hello STLS"
    },
    "extensions": {}
  }
}
```
### Step 5 - Lab Cleanup

```shell
kn service delete eventing-demo
kn trigger delete foo-trigger
kn trigger delete bar-trigger
kn broker delete stls-broker
```

```shell
kn service list && kn broker list && kn trigger list && kn service list
```
```text
No services found.
No brokers found.
No triggers found.
No services found.
```

### Workshop Cleanup

To stop the cluster, you can just stop the containers:
```shell
docker stop knative-control-plane
docker stop kind-registry
```

If you're ready to delete the cluster, just run:
```shell
kind delete cluster -n knative
```
