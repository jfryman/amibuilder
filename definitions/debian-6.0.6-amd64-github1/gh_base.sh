# Alias packages to our apt / gem server
grep -q packages.rs.github.com /etc/hosts || {
  echo >> /etc/hosts
  echo "207.97.227.238 packages packages.rs.github.com gems gems.rs.github.com gemserver gemserver.rs.github.com puppetmaster" >> /etc/hosts
}

cat >/etc/apt/sources.list <<EOF
deb http://ftp.us.debian.org/debian/ squeeze main
deb-src http://ftp.us.debian.org/debian/ squeeze main

deb http://security.debian.org/ squeeze/updates main
deb-src http://security.debian.org/ squeeze/updates main

deb http://ftp.us.debian.org/debian/ squeeze-updates main
deb-src http://ftp.us.debian.org/debian/ squeeze-updates main
EOF

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y lsb-base lsb-release lsb-core libaugeas-ruby augeas-lenses ruby1.8 ruby1.8-dev build-essential rubygems1.8 libopenssl-ruby ntpdate parted