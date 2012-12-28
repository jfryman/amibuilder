cat > /root/bootstrap.sh <<EOF
#!/usr/bin/env bash
set -o errexit

hostname $1

function say() {
  message="$1"
  uri=https://github.campfirenow.com/room/276100/speak.json
  token=936798a79d41667db14d807513b94aa10a5b9ed1
  json="{\"message\":{\"body\":\"$message\"}}"
  curl -v -u $token:X -H "Content-Type: application/json" -d "$json" $uri
}

# Sleep until we can hit the packages server
until curl -s --connect-timeout 1 packages:9999 > /dev/null; do
  sleep 5
done

say "$(hostname -f) bootstrap continuing..."

echo >>/etc/apt/sources.list
echo "deb http://packages:9999/github squeeze main" >>/etc/apt/sources.list
wget http://packages:9999/github/github.key -O - | apt-key add -
apt-get update

gem install puppet facter --source http://gemserver/ --no-rdoc --no-ri

mkdir -p /etc/puppet
(
cat <<'EOP'
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
pluginsync=true
factpath=/var/lib/puppet/lib/facter

[agent]
server=puppetmaster
splay=false
runinterval=1800
report=true
environment=production
EOP
) > /etc/puppet/puppet.conf

if [ $branch ]; then
    options="--environment=${branch}"
else
    options=""
fi

/var/lib/gems/1.8/bin/puppet agent --test ${options}| tee /root/puppet.1.log
/usr/sbin/fgadm reload || true
/var/lib/gems/1.8/bin/puppet agent --test ${options}| tee /root/puppet.2.log
/usr/sbin/fgadm reload || true
apt-get -y upgrade
/var/lib/gems/1.8/bin/puppet agent --test ${options}| tee /root/puppet.3.log
/usr/sbin/fgadm reload || true
EOF

chmod +x /root/bootstrap.sh

# AWS Bootstrap Key
mkdir /root/.ssh
cat > /root/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCAa5Faaga5mvZHklgdVg90oxfGqCdzeLu882oTWcK2a2yX83Kb8rN5jz/pWZHHYx1d1S2r3ziNGdWDshEDlQJImM8iNrTKi+m65FRr/veY6+du0grAhTbFB3qj2PN9YRIQ4i44UX9VvquM2wiNzwEvswbwJ4gb3tmHAnX227ABYQWWlRsSqIyf6jvnO2bm+z+ye/3PCV4FQmF904Lza7JBlsy8mLf3we+BC/HVxxmpvmmjRfVwywZOruxkhCHlvB7Om+SlDz8Yf/D0pNiPMa63PYXT98i0F/1UR2Lkt3cqgHc3OPw2NVubw4oBZB2BJo5lOjdG1NrOYnUQTIroWg/t gh-cloud-aws
EOF
chmod -R 600 /root/.ssh