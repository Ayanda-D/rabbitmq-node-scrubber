# RabbitMQ Node Scrubber

Tool for removing nodes from cluster state.

## 1. Scrub a remote node from the cluster

To remove remote node `rabbit@remote-host` from a cluster, first execute `stop_app` on it as follows:

```
rabbitmqctl -n rabbit@remote-host stop_app
```

Next, on one of the other cluster nodes, remove/scrub off the `rabbit@remote-host` from the cluster state as follows:


```
rabbitmqctl -n rabbit@local-host eval "rabbit_node_scrubber:scrub( 'rabbit@remote-host' )."

```

## 2. Remove local node from cluster

To remove local node `rabbit@local-host` from a cluster, first execute a local `stop_app` on it as follows:

```
rabbitmqctl -n rabbit@local-host stop_app
```

Next, on the local cluster node, remove/scrub off the `rabbit@local-host` from the cluster state as follows:

```
rabbitmqctl -n rabbit_1 eval 'rabbit_node_scrubber:leave_cluster().'
```