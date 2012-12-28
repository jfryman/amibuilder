#Setting up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/bootstrap ALL=(ALL) ALL/bootstrap ALL=NOPASSWD:ALL/g' /etc/sudoers