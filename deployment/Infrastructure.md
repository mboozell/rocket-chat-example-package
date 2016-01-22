### Creating an image

Configure system: 

- Copy `files` folder to server
- `./setup.sh`

Capture image:

`waagent -deprovision`

From Powershell with Azure CLI:

- `azure config mode arm`
- `azure vm stop <resource group> <vm name>`
- `azure vm generalize <resource group> <vm name>`
- `azure vm capture <resource group> <vm name> <image prefix> -R <container dir> -t <template.json>`

### Deploy and configure virtual machines

Deploy environment

`New-AzureRmResourceGroupDeployment -Name SangLucciDeployment -ResourceGroupName sanglucci -TemplateFile .\environment.json`

SSH in and finalize:

`config-dev.sh` or `config-prod.sh`

#### Connect Mongo replica set

- Create replica set [[13]]; in mongo shell:
	- `rs.initiate()`
	- `rs.conf()` should show one member
	- Add secondary: `rs.add("secondary")`
	- Add arbiter: `rs.addArb("arbiter")`
	- Check `rs.status()`
	- Change priorities:

```
cfg = rs.conf();
cfg.members[1].priority=0.5
cfg.members[2].priority=0.5
rs.reconfig(cfg);
```
### Prepare for deployments

-  Add server to Octopus Deployment for appropriate environments

[1]: http://blogs.msdn.com/b/igorpag/archive/2014/10/23/azure-storage-secrets-and-linux-i-o-optimizations.aspx
[2]: https://github.com/RocketChat/Rocket.Chat/wiki/Deploy-Rocket.Chat-without-docker 
[3]: https://docs.mongodb.org/manual/administration/production-notes/
[4]: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-optimize-mysql-perf/
[5]: https://docs.mongodb.org/manual/tutorial/transparent-huge-pages/
[6]: http://serverfault.com/questions/695616/how-to-create-a-swap-for-azure-ubuntu-vm 
[7]: https://azure.microsoft.com/en-us/blog/swap-space-in-linux-vms-on-windows-azure-part-2/
[8]: https://docs.mongodb.org/ecosystem/platforms/windows-azure/
[9]: http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-configure-raid
[10]: https://docs.mongodb.org/manual/core/security-mongodb-configuration/#http-interface-security
[11]: https://docs.mongodb.org/manual/reference/ulimit/
[12]: https://www.digitalocean.com/community/tutorials/how-to-implement-replication-sets-in-mongodb-on-an-ubuntu-vps
[13]: https://docs.mongodb.org/manual/tutorial/add-replica-set-arbiter/

