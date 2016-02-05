# Troubleshooting

For production mainly.

## Faults that go undetected in monitoring

### Chat is responsive but some feature is not working correctly

Check RC logs for exceptions.

### Site loads but chat is unresponsive

Check RC logs. 
Check datadog for downtime or any extreme readings on any of the graphs.
Check Mongo status

## Faults monitored by datadog

### Some users got the "disconnected, reconnecting..." RC message

Most likely the server they were connected to went down.

If the host went down for a known reason, they have to wait. If it went down for unknown reasons, you should have received a datadog alert for it.

When/if the load balancer deems the host as unhealthy, the user will be routed to another available host. This takes 10-15 seconds to happen on the backend (see health checks intervals). RocketChat uses a progressive back-off for retries so it can take I guess up to half a minute. 

### Site does not load at all

Most likely something in the pipeline has gone down on ALL nodes. 

Check nginx, node, mongo on datadog first and then on the VMs. 

### A `node` process is down

Normally it will be restarted by Upstart, unless it fails consecutively. 

Check logs for what is preventing the process from restarting.
Check that `current` symlink is valid (it would point to a problem with the deployment process) 

### `nginx` is down

Check nginx configuration is valid.
Check nginx logs. 

### `Mongo` is down

Check Mongo logs

### Data is missing (agent down)

Check datadog agent logs

## HOWTO

### Check RocketChat logs

*Note: most errors are in `error.log` but often `output.log` will contain errors because some code calls `console.log` instead of `console.error`:

```
# cd /var/log/apps/SangLucci.Chat/Web.Production/
# tail -n 20 -f error.log out.log
```

If there are errors and not visible, use `less` and press `END`:

```
# less error.log
```

### Check if node process is up

```
# ps aux | grep [S]angLucci
```

Example output:

```
sangluc+  5932  2.3  7.6 1299120 268252 ?      Ssl  11:06   5:27 node /var/apps/SangLucci.Chat/Web.Production/current/bundle/rocketchat
```

### Check if nginx configuration is valid

```
# nginx -t
```

Should be:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Check what RocketChat version is running (current symlink)

```
# readlink /var/apps/SangLucci.Chat/Web.Production/current

/var/apps/SangLucci.Chat/Web.Production/1.0.0.91

```

### Check MongoDB status

```
# mongo
> rs.status()
```

e.g.

```
rs0:PRIMARY> rs.status()
{
        "set" : "rs0",
        "date" : ISODate("2016-01-26T21:58:27.089Z"),
        "myState" : 1,
        "term" : NumberLong(-1),
        "heartbeatIntervalMillis" : NumberLong(2000),
        "members" : [
                {
                        "_id" : 0,
                        "name" : "sanglucci-primary:27017",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 468462,
                        "optime" : Timestamp(1453845506, 1),
                        "optimeDate" : ISODate("2016-01-26T21:58:26Z"),
                        "electionTime" : Timestamp(1453377051, 1),
                        "electionDate" : ISODate("2016-01-21T11:50:51Z"),
                        "configVersion" : 4,
                        "self" : true
                },
                {
                        "_id" : 1,
                        "name" : "sanglucci-secondary:27017",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 30303,
                        "optime" : Timestamp(1453845506, 1),
                        "optimeDate" : ISODate("2016-01-26T21:58:26Z"),
                        "lastHeartbeat" : ISODate("2016-01-26T21:58:26.795Z"),
                        "lastHeartbeatRecv" : ISODate("2016-01-26T21:58:25.092Z"),
                        "pingMs" : NumberLong(0),
                        "syncingTo" : "sanglucci-primary:27017",
                        "configVersion" : 4
                },
                {
                        "_id" : 2,
                        "name" : "sanglucci-arb:27017",
                        "health" : 1,
                        "state" : 7,
                        "stateStr" : "ARBITER",
                        "uptime" : 468457,
                        "lastHeartbeat" : ISODate("2016-01-26T21:58:25.488Z"),
                        "lastHeartbeatRecv" : ISODate("2016-01-26T21:58:26.505Z"),
                        "pingMs" : NumberLong(0),
                        "configVersion" : 4
                }
        ],
        "ok" : 1
}

```

### Log locations and commands to control services

#### RocketChat - Sang Lucci

`start|stop|restart SangLucci.Chat-Web.Production`

`/var/apps/SangLucci.Chat/Web.Production/error|output.log`

#### RocketChat - HFTAlert

`start|stop|restart HFTAlert.Chat-Web.Production`

`/var/apps/HFTAlert.Chat/Web.Production/error|output.log`

#### nginx

`service nginx start|stop|restart`

`var/log/nginx/error.log`

#### mongo

`service mongod start|stop|restart`

`var/log/mongodb/mongod.log`

#### datadog-agent

`/etc/init.d/datadog-agent start|stop|restart`

`/var/log/datadog/collector.log`
