#!/usr/bin/env bash

apt-get install -y linux-image-xen-amd64

if [[ ! -e /boot/grub ]]; then
  mkdir -p /boot/grub
fi

apt-get update
apt-get remove --purge grub-legacy
apt-get install grub2
apt-get --purge autoremove

# remove the old menu.lst
rm /boot/grub/menu.lst

# disable the default configs
chmod -x /etc/grub.d/*

# get the custom config
wget --no-check-certificate https://raw.github.com/tomheady/ec2debian/master/src/root/etc/grub.d/40_custom -O /etc/grub.d/40_custom

# enable the custom config
chmod +x /etc/grub.d/40_custom

update-grub

# link the new config to the place the pvgrub
ln -s /boot/grub/grub.cfg /boot/grub/menu.lst

apt-get -y dist-upgrade

# fstab entries
cat > /etc/fstab <<EOF
/dev/xvda1 /     ext4    defaults,barrier=0 1 1
EOF

# Network Interface Configuration
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
