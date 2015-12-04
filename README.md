# SangLucci Rocket Chat

## Build process

Commits to this repository are picked up by TeamCity hosted at [http://build.flmr.io](http://build.flmr.io) and a build is executed automatically with the included changes. 

The build will essentially run `meteor build` with target architecture `linux_x86_64` and package the output tarball into a NuGet package for deployment with Octopus Deploy.

If the build finishes successfully, the dependent task (Create Release for Build) will be triggered which will launch a deployment to the `Web.Development` environment automatically. 

## Environments

We currently have 3 environments: `Web.Development`, `Web.QA` (User acceptance) and `Web.Production`. The deployment lifecycle dictates that deployments must be promoted in this order. 

The `Web.Development` and `Web.QA` environments exist on `sanglucci1.eastus.cloudapp.azure.com` and `Web.Production` on `sanglucci0.eastus.cloudapp.azure.com`.

The server is a Linux VM hosted on `Azure` (Standard A2 instance for production) running `Ubuntu Server 14.04 LTS`. `MongoDB` is configured (each environment has its own DB instance) and `Nginx` serves to proxy requests to the `node` instances. Node instances are kept alive with the `Upstart`.

## Deployment and troubleshooting

After deploying the meteor package to the target environment, it is unpacked to `/var/apps/SangLucci.Chat/ENVIRONMENT_NAME/VERSION`. The current deployment is symlinked to `/var/apps/SangLucci.Chat/ENVIRONMENT_NAME/current`. Once npm packages are successfully installed, the symlink is changed to the new version and the service restarted. 

### Troubleshooting

The deployment script will exit if any command exits with an error and its output is captured by Octopus. 

In cases when further troubleshooting is necessary the relevant log files are:

- Upstart log file: `/var/log/upstart/SangLucci.Chat-ENRIVONRMENT_NAME` 
- Node output log file: `/var/log/SangLucci.Chat/ENVIRONMENT_NAME/*.log`

