## Best practices

http://blogs.msdn.com/b/igorpag/archive/2014/10/23/azure-storage-secrets-and-linux-i-o-optimizations.aspx

- Azure data disks must be mounted by UUID
- Caching for workloads that are not write-intensive should be Read-Write (required by Mongo)
- Set replication to LRS and have geo-replicated backups
- Add swap file in /dev/sdb - ext4 or xfs - http://serverfault.com/questions/695616/how-to-create-a-swap-for-azure-ubuntu-vm https://azure.microsoft.com/en-us/blog/swap-space-in-linux-vms-on-windows-azure-part-2/
- Disable file access time tracking by adding `noatime` in `/etc/fstab` (instead of defaults) 
- Create RAID-0 disk array with MD, 64KB chunks - http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-configure-raid
- Change disk scheduling algo for SSD to NOOP or DEADLINE - https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-optimize-mysql-perf/

## Mongo configuration

- Set dbpath/logpath to RAID array
- Requires read-write cache - https://docs.mongodb.org/ecosystem/platforms/windows-azure/
- Add replSet with 3 members or 2 members+arbitrer
- Disable HTTP access if enabled - https://docs.mongodb.org/manual/core/security-mongodb-configuration/#http-interface-security
- Use NOOP scheduler
- Use XFS

- Turn off atime for the storage volume containing the database files.
- Set the file descriptor limit, -n, and the user process limit (ulimit), -u, above 20,000, according to the suggestions in the ulimit document. A low ulimit will affect MongoDB when under heavy use and can produce errors and lead to failed connections to MongoDB processes and loss of service. https://docs.mongodb.org/manual/reference/ulimit/
- Disable Transparent Huge Pages, as MongoDB performs better with normal (4096 bytes) virtual memory pages. https://docs.mongodb.org/manual/tutorial/transparent-huge-pages/
- Ensure that readahead settings for the block devices that store the database files are appropriate. For random access use patterns, set low readahead values. A readahead of 32 (16 KB) often works well.
For a standard block device, you can run sudo blockdev --report to get the readahead settings and sudo blockdev --setra <value> <device> to change the readahead settings.
- Use the Network Time Protocol (NTP) to synchronize time among your hosts.

- Backups: https://docs.mongodb.org/manual/core/backups/

Sources:
https://docs.mongodb.org/manual/administration/production-notes/

## Meteor config

- Commit environment variables for each environment in Git
- Set MONGO_OPLOG_URL to enable oplog

- forever to restart if app crashes
- stud for SSL

## Monitoring

datadog / new relic

## Monitoring alerts


## Setting up a virtual machine for Rocket Chat deployment

### Creating the VM
- Create Azure VM
	- Name: `sanglucciX` (X = number)
	- Attach to `sanglucci` virtual network with IP `10.0.0.X`
	- Set up login with SSH key only
	- VHD storage in `sangluccim` storage account.
- Attach 2 data disks, 10GB each, read-only cache, on `sangluccim` storage account under `datadisks` container. Name them as `sanglucciX-storage-Y` where `Y=0,1`

### Configure basic system

- `do-release-upgrade`
- `unattended-upgrade` (automatic security patch installation)

- Create RAID disk from the data disks: `apt-get install mdadm --no-install-recommends && mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdc /dev/sdd && mkfs.ext3 /dev/md0 && mkdir /storage && mount /dev/md0 /storage && mdadm --detail --scan >> /etc/mdadm/mdadm.conf`
- Add RAID entry from `mdadm.conf` to fstab: `UUID=UUID_FOR_RAID_ARRAY /storage auto defaults,nobootwait 0 2` (find UUID with `blkid`)
- Add `AUTOSTART=true` to `/etc/default/mdadm`
- Update initrd: `update-initramfs -u`
- Add user `sanglucci` with SSH key and add to sudoers:
	- `useradd -N -m sanglucci; mkdir /home/sanglucci/.ssh; chown sanglucci.sanglucci /home/sanglucci/.ssh; echo "KEY_HERE" > /home/sanglucci/.ssh/authorized_keys; echo "sanglucci ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sanglucci `
- Add utils: `apt-get install -y where zip mc htop`

### Install web infrastructure software

- Install required packages: `apt-get install -y nginx g++ make`
- Install mongodb: `apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10; echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list; apt-get update; apt-get install -y mongodb-org`
- Install node.js: `curl https://raw.githubusercontent.com/creationix/nvm/v0.17.3/install.sh | bash; source ~/.profile; source ~/.bashrc; nvm install v0.10.40; n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; sudo cp -r $n/{bin,lib,share} /usr/local`

### Configure web infrastructure

- Copy SSL certificates over to `/etc/ssl/certs`and `/etc/ssl/private`
- Create dhparam: `cd /etc/ssl/certs && openssl dhparam -out dhparam.pem 2048`
- Copy SSL settings to nginx

```
		##
        # SSL Settings
        ##

        ssl_protocols                           TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4";
        ssl_prefer_server_ciphers               on;
        ssl_stapling                            on;
        ssl_stapling_verify                     on;
        ssl_dhparam                             /etc/ssl/certs/dhparam.pem;
        ssl_session_cache                       shared:SSL:10m;
        ssl_session_timeout                     10m;

        # config to enable HSTS(HTTP Strict Transport Security) https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security
        # to avoid ssl stripping https://en.wikipedia.org/wiki/SSL_stripping#SSL_stripping
        add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

```

- Create `/etc/nginx/sites-available/` entries and link them to the `sites-enabled` dir
- Check nginx config: `nginx -t`

### Configure environments

- Create app storage directory in RAID volume: `mkdir -p /storage/apps/SangLucci.Chat; chown sanglucci.sanglucci /storage/apps/SangLucci.Chat`
- Create logs and deployment directories: `cd /storage/apps/SangLucci.Chat; su sanglucci; mkdir logs; mkdir deployments; exit`
- Link to "proper" directories: `ln -s /storage/apps/SangLucci.Chat/logs /var/log/SangLucci.Chat; mkdir /var/apps; ln -s /storage/apps/SangLucci.Chat/deployments /var/apps/SangLucci.Chat`

### Create chat services

- Add upstart config to `/etc/init`

### Prepare for deployments
- Install mono: `apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF; echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list; apt-get update; apt-get install -y mono-complete`
-  Add server to Octopus Deployment for appropriate environments

### Finalize

-  Upgrade packages: `apt-get upgrade`

### Monitoring and maintenance

- Install datadog: `DD_API_KEY=37b7f7b2aa9cafbef4a015e77b2ac18c bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"`
