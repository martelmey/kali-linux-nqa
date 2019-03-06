#!/bin/bash

# Kali Linux ISO recipe for : No Questions Asked
##########################################################################
# Desktop 		: XFCE, GNOME
# Metapackages	: kali-linux, kali-linux-wireless, kali-linux-web, kali-linux-pwtools
# ISO size 		: TBD
# Special notes	: 
# Background	: http://www.offensive-security.com/kali-linux/kali-linux-recipes/
##########################################################################

# Update, install dependencies

cd $HOME
apt-get update
apt-get install git live-build cdebootstrap -y

# Clone default Kali live-build-config

git clone git://git.kali.org/live-build-config.git

# Customizations:

cd live-build-config
cat <<EOF > kali-config/variant-light/package-lists/kali.list.chroot
kali-desktop-live
kali-desktop-xfce
kali-desktop-gnome
kali-linux
kali-linux-wireless
kali-linux-web
kali-linux-pwtools
EOF

# Nonadmin user

mkdir -p config/includes.chroot/etc/nonadmin
touch config/includes.chroot/etc/nonadmin/nonadmin.sh
echo adduser --ingroup sudo nonadmin > config/includes.chroot/etc/nonadmin/nonadmin.sh
chmod 755 config/includes.chroot/etc/nonadmin/nonadmin.sh

# Preseeding

cd kali-config/common/hooks
touch 02-unattended-boot.binary
cat <<EOF > 02-unattended-boot.binary
#!/bin/sh
cat >>binary/isolinux/install.cfg < label install
menu label ^Unattended Install
menu default
linux /install/vmlinuz
initrd /install/initrd.gz
append vga=788 -- quiet file=/cdrom/install/preseed.cfg locale=en_US keymap=us hostname=kali domain=local.lan
END
EOF
chmod 755 live-build-config/kali-config/common/hooks/02-unattended-boot.binary

wget https://www.kali.org/dojo/preseed.cfg -O ./kali-config/common/includes.installer/preseed.cfg

# Run the build!
./build.sh --variant light --verbose