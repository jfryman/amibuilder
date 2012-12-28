apt-get install linux-image-xen-amd64
mkdir /boot/grub
apt-get install grub-legacy

# Custom configuration to generate 
cat >/etc/grub.d/40_custom <<EOG
#!/bin/sh

# This file generates the old menu.lst configuration with grub2
# It was copied from tomheadys github repo:
# https://github.com/tomheady/ec2debian/blob/master/src/root/etc/grub.d/40_custom

prefix=/usr
exec_prefix=${prefix}
bindir=${exec_prefix}/bin
libdir=${exec_prefix}/lib
. ${libdir}/grub/grub-mkconfig_lib

export TEXTDOMAIN=grub
export TEXTDOMAINDIR=${prefix}/share/locale

GRUB_DEVICE=/dev/xvda1

cat << EOF
default 0
timeout 1
EOF

linux_entry ()
{
  os="$1"
  version="$2"
  args="$4"

  title="$(gettext_quoted "%s, with Linux %s")"

  cat << EOF
title ${version}
  root (hd0)
  kernel ${rel_dirname}/${basename} root=${GRUB_DEVICE} ro ${args}
  initrd ${rel_dirname}/${initrd}
EOF
}

list=`for i in /boot/vmlinuz-* /boot/vmlinux-* /vmlinuz-* /vmlinux-* ; do
        if grub_file_is_not_garbage "$i" ; then echo -n "$i " ; fi
      done`
prepare_boot_cache=

while [ "x$list" != "x" ] ; do
  linux=`version_find_latest $list`
  basename=`basename $linux`
  dirname=`dirname $linux`
  rel_dirname=`make_system_path_relative_to_its_root $dirname`
  version=`echo $basename | sed -e "s,^[^0-9]*-,,g"`
  alt_version=`echo $version | sed -e "s,\.old$,,g"`
  linux_root_device_thisversion="${LINUX_ROOT_DEVICE}"

  initrd=
  for i in "initrd.img-${version}" "initrd-${version}.img" \
       "initrd-${version}" "initramfs-${version}.img" \
       "initrd.img-${alt_version}" "initrd-${alt_version}.img" \
       "initrd-${alt_version}" "initramfs-${alt_version}.img"; do
    if test -e "${dirname}/${i}" ; then
      initrd="$i"
      break
    fi
  done

  initramfs=
  for i in "config-${version}" "config-${alt_version}"; do
    if test -e "${dirname}/${i}" ; then
      initramfs=`grep CONFIG_INITRAMFS_SOURCE= "${dirname}/${i}" | cut -f2 -d= | tr -d \"`
      break
    fi
  done

  linux_entry "${OS}" "${version}" \
      "${GRUB_CMDLINE_LINUX} ${GRUB_CMDLINE_LINUX_DEFAULT}"

  list=`echo $list | tr ' ' '\n' | grep -vx $linux | tr '\n' ' '`
done
EOG

chmod +x /etc/grub.d/40_custom
update-grub

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