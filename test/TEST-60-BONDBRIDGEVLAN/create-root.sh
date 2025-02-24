#!/bin/sh

trap 'poweroff -f' EXIT

# don't let udev and this script step on eachother's toes
for x in 64-lvm.rules 70-mdadm.rules 99-mount-rules; do
    : > "/etc/udev/rules.d/$x"
done
rm -f -- /etc/lvm/lvm.conf
udevadm control --reload
udevadm settle
set -e
# save a partition at the beginning for future flagging purposes
sfdisk /dev/sda << EOF
,1M
,
EOF

udevadm settle
mkfs.ext4 -L dracut /dev/sda2
mkdir -p /root
mount -t ext4 /dev/sda2 /root
cp -a -t /root /source/*
mkdir -p /root/run
umount /root
echo "dracut-root-block-created" | dd oflag=direct,dsync of=/dev/sda1
sync
poweroff -f
