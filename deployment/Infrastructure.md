## Creating an image

### Configure system
- `do-release-upgrade`
- `apt-get upgrade`
- Automatically install upgrades: `dpkg-reconfigure --priority=low unattended-upgrades`
- Change machine timezone to ET: `dpkg-reconfigure tzdata`
- Change cron.daily to run after market close (4AM ET): edit `/etc/crontab`
- Setup NTP sync [[3]]: `apt-get install ntp`
- Use NOOP scheduler [[1]] [[3]]: Add `elevator=noop` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`. Run `update-grub`
- Disable Transparent Huge Pages, as MongoDB performs better with normal (4096 bytes) virtual memory pages. [[3]] [[5]]
- Configure VM Agent to automatically add a swap file in /dev/sdb [[6]]; [[7]]: ``mem=`free -m | grep -oP '\d+' | head -n 1`; sed -i -e "s/\(ResourceDisk.EnableSwap *= *\).*/\1y/" -e "s/\(ResourceDisk.Format *= *\).*/\1y/" -e "s/\(ResourceDisk.SwapSizeMB *= *\).*/\1$mem/" /etc/waagent.conf > /etc/waagent.conf``
- Add user `sanglucci` with SSH key and add to sudoers: `useradd -m sanglucci; mkdir /home/sanglucci/.ssh; chown sanglucci.sanglucci /home/sanglucci/.ssh; echo "ssh-rsa KEY" > /home/sanglucci/.ssh/authorized_keys; echo "sanglucci ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sanglucci`

### Install software

- Packages: `apt-get install -y zip mc htop g++ make npm curl graphicsmagick mdadm xfsprogs lynx` [[2]]
- mongodb: `apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10; echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list; apt-get update; apt-get install -y mongodb-org`
- node.js: 
	- Install `n`: `npm install -g n`
	- `n 0.10.40`
- mono: `apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF; echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list; apt-get update; apt-get install -y mono-complete`

### Capture image

- Edit `/etc/waagent.conf`:

```
Provisioning.Enabled=y
Provisioning.DeleteRootPassword=n
Provisioning.RegenerateSshHostKeyPair=y
Provisioning.SshHostKeyPairType=rsa
Provisioning.MonitorHostName=y
Provisioning.DecodeCustomData=n
Provisioning.ExecuteCustomData=n
```

- `waagent -deprovision`

From Powershell with Azure CLI:

- `azure config mode arm`
- `azure vm stop <resource group> <vm name>`
- `azure vm generalize <resource group> <vm name>`
- `azure vm capture <resource group> <vm name> <image prefix> -R <container dir> -t <template.json>`

### Deploy and configure virtual machines

`New-AzureRmResourceGroupDeployment -Name SangLucciDeployment -ResourceGroupName sanglucci -TemplateFile .\deployment.json`

#### For all

- Add names to `/etc/hosts`

```
127.0.0.1 THIS_HOSTNAME
10.0.0.4 sanglucci-primary
10.0.0.5 sanglucci-secondary
10.0.0.6 sanglucci-arb
```

- Set `Provisioning.Enabled=n` in `/etc/waagent.conf` to prevent SSH keys to be regenerated on every reboot
- Remove dupe key from `/home/georgiosd/.ssh/authorized_keys`

#### For 2x Mongo nodes

- Set up RAID-0 between data disks
	- Create RAID-0 disk array with MD, 64KB chunks [[9]]:
		- `cfdisk /dev/hd[c,d]`
		- `mdadm --create /dev/md127 --level=0 --chunk=64 --raid-devices=2 /dev/sdc1 /dev/sdd1`
		- `mkfs -t xfs /dev/md127`
		- `mkdir /storage`
		- Get UUID from `blkid`
		- Add to `/etc/fstab`: `UUID=uuid_here /storage xfs defaults,noatime,nobootwait 0 2` [[4]]
		- `mount -a` to test
		- Set readahead to 32 (16 KB); `blockdev --setra 32 /dev/md127`

- Configure mongo:
	- `mkdir /storage/db; chown mongodb.mongodb /storage/db/`
	- Set dbpath/logpath to RAID array
	- Set `replSetName: rs0` in `mongod.conf`
	- Add vnet ip to `bindIp` (no spaces)

#### For Arbiter

- Set `journal.enabled=false`
- Set `smallFiles=false` 
- Set `replSetName: rs0` in `mongod.conf`

#### Finally 

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

### Set up application

`mkdir /storage/apps; chown sanglucci.sanglucci /storage/apps; ln -s /storage/apps /var/apps; mkdir /var/log/apps; chown sanglucci.sanglucci /var/log/apps`

#### Upstart

`/etc/init/SangLucci.Chat-Web.Production.conf`:

```
description "SangLucci Chat (Production)"

start on started mongod and runlevel [2345]
stop on shutdown

respawn
respawn limit 10 5

setuid sanglucci
setgid sanglucci

script
    APPLICATION="SangLucci.Chat"
    ENVIRONMENT="Web.Production"
    DB=$(echo "$APPLICATION-$ENVIRONMENT" | tr . _)

    export ROOT_URL=https://sanglucci.eastus.cloudapp.azure.com

    export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export NODE_PATH=/usr/lib/nodejs:/usr/lib/node_modules:/usr/share/javascript

    export PWD=/home/sanglucci
    export HOME=/home/sanglucci

    export BIND_IP=$(hostname -I)
    export PORT=8080
    export HTTP_FORWARDED_COUNT=1
    export MONGO_URL="mongodb://sanglucci-primary:27017,sanglucci-secondary:27017,sanglucci-arb:27017/$DB?replicaSet=rs0&readPreference=nearest&w=majority"
    export MONGO_OPLOG_URL="mongodb://sanglucci-primary:27017,sanglucci-secondary:27017,sanglucci-arb:27017/local"

    APP_DIR=/var/apps/$APPLICATION/$ENVIRONMENT
    LOG_DIR=/var/log/apps/$APPLICATION/$ENVIRONMENT

    exec node $APP_DIR/current/bundle/main.js 2>> $LOG_DIR/error.log >> $LOG_DIR/out.log
end script

```

### Meteor config

- Commit environment variables for each environment in Git
- forever to restart if app crashes
- stud for SSL

## Backups

- Backups: https://docs.mongodb.org/manual/core/backups/
- To geo-replicated account

## Monitoring

datadog / new relic

## Monitoring alerts


### Configure SSL

- Copy SSL certificates over to `/etc/ssl/certs`and `/etc/ssl/private`

### Configure environments

- Create app storage directory in RAID volume: `mkdir -p /storage/apps/SangLucci.Chat; chown sanglucci.sanglucci /storage/apps/SangLucci.Chat`
- Create logs and deployment directories: `cd /storage/apps/SangLucci.Chat; su sanglucci; mkdir logs; mkdir deployments; exit`
- Link to "proper" directories: `ln -s /storage/apps/SangLucci.Chat/logs /var/log/SangLucci.Chat; mkdir /var/apps; ln -s /storage/apps/SangLucci.Chat/deployments /var/apps/SangLucci.Chat`

### Create chat services

- Add upstart config to `/etc/init`

### Prepare for deployments

-  Add server to Octopus Deployment for appropriate environments

### Monitoring and maintenance

- Install datadog: `DD_API_KEY=37b7f7b2aa9cafbef4a015e77b2ac18c bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"`


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

