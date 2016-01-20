#!/bin/bash -v

app=`get_octopusvariable "Octopus.Action[Unpack package].Package.NuGetPackageId"`
version=`get_octopusvariable "Octopus.Action[Unpack package].Package.NuGetPackageVersion"`
environment=`get_octopusvariable "Octopus.Environment.Name"`
serviceName="$app-$environment"
logDirectory="/var/log/apps/$app/$environment/"

echo "Updating $app to $version ($environment)"

# source and destination
bundle=`ls -f $HOME/.octopus/Applications/OctopusServer/$environment/$app/$version/*.tar.gz`
dest="/var/apps/$app/$environment/$version"
perm="/var/apps/$app/$environment/current"
prev_perm=`readlink -e $perm`

echo "Bundle used: $bundle"
echo "Destination: $dest"   
echo "Previous deployment: $prev_perm"

# delete and/or create directory
rm -rf $dest
mkdir -p $dest || exit 1
mkdir -p $logDirectory || exit 1

# extract bundle
echo "Extracting bundle to $dest ..."
tar -zxf $bundle -C $dest --overwrite --touch || exit 1

# install packages - reduce npm logging to error because it throws OD off
echo "Installing npm packages"
cd $dest/bundle/programs/server
sudo npm config set loglevel error
npm install > /dev/null 2>&1 || exit 1

# give ourselves permissions
cd $dest
chmod 775 bundle
sudo chown -R sanglucci.sanglucci bundle

# link version to permanent place after deleting old link
echo "Linking $dest to $perm"
rm -f $perm
ln -s $dest $perm || exit 1

# create daemon script

cat <<EOF > $dest/bundle/rocketchat
#!/usr/bin/env node

var tzoffset = (new Date()).getTimezoneOffset() * 60000;
var localISOTime = function() {
  return (new Date(Date.now() - tzoffset)).toISOString().slice(0,-1);
}

var getTimestampedLogFunc = function(orig) {
  return function() {
    if(arguments && arguments.length > 0 && typeof arguments[0] == "string")
      arguments[0] = localISOTime() + " " + arguments[0];
    else
      [].unshift.call(arguments, localISOTime());
    return orig.apply(console, arguments);
  };
};

console.log = getTimestampedLogFunc(console.log);
console.error = getTimestampedLogFunc(console.error);

EOF

cat $dest/bundle/main.js >> $dest/bundle/rocketchat
chown sanglucci.sanglucci $dest/bundle/rocketchat
chmod +x $dest/bundle/rocketchat

# restart service
echo "Restarting $serviceName"
pid_file="/var/run/apps/$app-$environment.pid"
if [ -f $pid_file ] && [ -e /proc/$(cat $pid_file) ]; then
	sudo stop $serviceName
fi

sudo start $serviceName

sleep 30s

if [ ! -f $pid_file ] || [ ! -e /proc/$(cat $pid_file) ]; then
	>&2 echo "Service failed to start!"
	exit 1
fi

# delete old files
echo "Deleting old deployment at $prev_perm"
rm -rf $prev_perm

echo "Done."
