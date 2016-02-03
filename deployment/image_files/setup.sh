#!/bin/bash

pause(){
 read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

# Change cron.daily to run after market close (4AM ET)
echo "Change cron.daily to run after market close (4AM ET)"
pause
nano /etc/crontab

#### Start auto stuff

do-release-upgrade
apt-get upgrade -y

# Automatically install upgrades: 
dpkg-reconfigure --priority=low unattended-upgrades

# Change machine timezone to ET: 
dpkg-reconfigure tzdata


# Setup NTP sync [[3]]: 
apt-get install -y ntp

# Use NOOP scheduler [[1]] [[3]]: Add `elevator=noop` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`.
sed 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="elevator=noop /g' /etc/default/grub
update-grub

# Disable Transparent Huge Pages, as MongoDB performs better with normal (4096 bytes) virtual memory pages. [[3]] [[5]]
cp disable-transparent-hugepages /etc/init.d
chmod 755 /etc/init.d/disable-transparent-hugepages
update-rc.d disable-transparent-hugepages defaults

# Configure VM Agent 

# Automatically add a swap file in /dev/sdb [[6]]; [[7]]: 
mem=`free -m | grep -oP '\d+' | head -n 1`
sed -i -e "s/\(ResourceDisk.EnableSwap *= *\).*/\1y/" /etc/waagent.conf
sed -i -e "s/\(ResourceDisk.Format *= *\).*/\1y/" /etc/waagent.conf
sed -i -e "s/\(ResourceDisk.SwapSizeMB *= *\).*/\1$mem/" /etc/waagent.conf

# Enable provisioning
sed -i -e "s/\(Provisioning.Enabled *= *\).*/\1y/" /etc/waagent.conf
sed -i -e "s/\(Provisioning.DeleteRootPassword *= *\).*/\1n/" /etc/waagent.conf
sed -i -e "s/\(Provisioning.RegenerateSshHostKeyPair *= *\).*/\1y/" /etc/waagent.conf
sed -i -e "s/\(Provisioning.MonitorHostName *= *\).*/\1y/" /etc/waagent.conf


# Add user `sanglucci` with SSH key and add to sudoers 
useradd -m sanglucci 
mkdir /home/sanglucci/.ssh 
chown sanglucci.sanglucci /home/sanglucci/.ssh
# Public key added by deployment
#echo "Enter public key for user sanglucci:"
#read SANGLUCCI_PUBLIC_KEY
#echo "ssh-rsa $SANGLUCCI_PUBLIC_KEY" > /home/sanglucci/.ssh/authorized_keys
echo "sanglucci ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sanglucci

# mongodb + mono
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list; 

# packages 
apt-get update
apt-get install -y zip mc htop g++ make npm curl graphicsmagick mdadm xfsprogs lynx mongodb-org mono-complete nginx

# NPM utils + node js
npm install -g azure-cli n
n 0.10.40

# Add SSL keys to /etc/ssl
tar -xf ssl.tar -C /etc

# Disable default nginx site
rm -rf /etc/nginx/sites-enabled/default
