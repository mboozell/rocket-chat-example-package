# SangLucci Rocket Chat

Our build server, TeamCity can be found at [http://build.flmr.io](http://build.flmr.io).
Our deployment server, Octopus Deploy, can be found at [http://deploy.flmr.io](http://deploy.flmr.io)

Both of the above services are hosted on the `FLMRIO` VM which also hosts other services (last update: Jan 26, 2016). 

## Build process

Commits to this repository are automatically picked up by TeamCity and a build is executed with all the included changes, incrementing the build number. If the server is turned-off at the time of a commit, a build will be triggered as soon as it is up. 

The build uses a PowerShell script to run `meteor build` with target architecture `linux_x86_64` and package the output tarball into a NuGet package for deployment.

## Deployment

We have 3 environments: `Web.Development`, `Web.QA` (User acceptance) and `Web.Production`. The deployment lifecycle configured in Octopus dictates that deployments must be promoted in this order. 

Both the `Web.Development` and `Web.QA` environments exist on the SangLucci development server and `Web.Production` on the cluster of production VMs.

Deployments/promotions can be triggered manually by going into Octopus and selecting a release to deploy to a target environment. 

*Note that a release fixes the Octopus settings; if Octopus settings are changed and the same package version must be deployed, the release must be deleted and recreated or a new release created.*

# Architecture

All servers are hosted on Azure, on Linux VMs running `Ubuntu Server 14.04 LTS`. 

The production environment is composed of 3 servers, the minimum to create a MongoDB replica set. However, because our current needs do not require that much processing power, two mongo nodes and an arbiter (used only for voting for a primary) is used. 

The two nodes that host a data-bearing mongo node are called `sanglucci-primary` and `sanglucci-secondary` respectively and use Azure `D1_v2` instances. The arbiter is called `sanglucci-arbiter` and is the smallest VM size `A0` because it does no processing other than voting in the replica set. As and when our processing needs increase, we will convert the arbiter to a data-bearing node.

Data-bearing nodes (primary, secondary) host a NodeJS process that serves requests to the chatroom. The database and application files are stored in `/storage` which is an auto-mounted RAID-0 array with two Azure data disks. 

Requests are load-balanced between the two nodes using a standard Azure load balancer. Nginx is used to offload SSL and provide HTTPS redirects for HTTP requests.

Diagrammatically:

												   HTTPS request
														 |
												====================
												|   Load balancer  |
												====================
														/  \		
													   /    \		SSL (HTTP requests are redirected to HTTPS)
													  /      \
												     /        \
									=====================	  =====================
									|  nginx (primary)  |     | nginx (secondary) |	(Ports 80, 443)
									=====================	  =====================
											  |							|																
									=====================	  =====================
									|    node process   |     |   node process    |	(Port 8080)
									=====================	  =====================
											 ()						   ()
									=====================	  =====================		=====================
									|     MongoDB       |     |     MongoDB       |		| MongoDB (arbiter) |	
									=====================	  =====================		=====================

There are no links to the MongoDB nodes because essentially the node processes can be talking to any one of them (except the arbiter) depending on settings. For our setup, the `read preference` is set to `nearest` meaning that the nodes will pick the mongo node that responds the fastest, which should be the local node under normal circumstances. The `write preference` is set to `majority` which means that a write request must be replicated before the operation finishes (to ensure no data loss).

The node processes are started and maintained using Upstart with the corresponding configuration files in `/etc/init/`.
The load balancer checks that the `http://primary,secondary:8080` endpoint returns a 2xx code to establish the health of a server; checks run every 5 seconds, after 2 consecutive failures a host is marked as unhealthy it is removed from the backend pool and no traffic is routed to that host until the health check is successful again.

Backups are taken hourly through a cron task that runs on the primary node on even hours and on the secondary node on odd hours. The process is configured to execute on the lowest priority (both CPU and I/O).

Updates are installed daily automatically. 4AM for the primary and arb and 7.35AM for the secondary (as soon as it wakes up).

During deployment, the package created by TeamCity is transferred to the server(s) and stored in `/home/sanglucci/octopus`. Then a script is executed that extracts it in `/var/apps` with the version number created as part of the path. A symlink is created to `current` such that it points to the currently running version and it doesn't require changing the paths in Upstart every time.

Misc notes about the configuration of the nodes:
- `/storage/apps` is symlinked to `/var/apps`
- Logs are in `/var/log/apps`
