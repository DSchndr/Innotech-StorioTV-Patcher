#!/bin/bash

version="0.1 Indev"
sdmountpoint=/dev/mmcblk0
sysmountpoint=/tmp
error="[ERR]: "
selection="[??]: "
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mainmenu()
{
clear
echo "-===InnoTV/StorioTV Patcher v$version ===-"
echo
echo "               .:Menu:."
echo "1)  Set Mountpoint for SD (Currently: $sdmountpoint)"
echo "2)  Set Mountpoint for the Sys-Partition (Currently: $sysmountpoint)"
echo "3)  Make an Backup of the SD-Card"
echo "4)  Dump the Sys-Partition"
echo "5)  Dump the Boot-Partition"
echo "6)  Flash the Sys-Partition"
echo "7)  Flash the Boot-Partition"
echo "8)  Patch Parentalcontrols.apk and install the patched version"
echo "9)  Enable ADB and Root"
echo "10) (Un)Mount the Sys-Partition"
#echo "11) Make everything automated"

read -p $selection value
if (( $value > 11 ))
then
echo "$error Invalid selection $value"
return 1
fi
if (( $value < 0 ))
then
echo "$error Invalid selection $value"
return 1
fi

if [ $value = 1 ]
then
setmountsd
fi
if [ $value = 2 ]
then
setmountsyspart
fi
if [ $value = 3 ]
then
backupfullsd
fi
if [ $value = 4 ]
then
backupsyspart
fi
if [ $value = 5 ]
then
backupbootpart
fi
if [ $value = 6 ]
then
flashsyspart
fi
if [ $value = 7 ]
then
flashbootpart
fi
if [ $value = 8 ]
then
instprogs
fi
if [ $value = 9 ]
then
enableadbandroot
fi
if [ $value = 10 ]
then
mountsys
fi
if [ $value = 11 ]
then
doallforme
fi
mainmenu
}

setmountsd() {
clear
echo "Where is the SD-Card? (eg. $sdmountpoint)"
read -p $selection value
sdmountpoint=$value
}

setmountsyspart() {
clear
echo "Where should the SYS partition be mounted? (eg. $sysmountpoint)"
read -p $selection value
sysmountpoint=$value
}

backupfullsd() {
clear
echo "Makeing the backup of the SD-Card..."
sudo dd if=$sdmountpoint of=SDCardbackup.bin
echo "Done! Press enter."
read
}

backupsyspart() {
clear
echo "Dumping the System partition..."
sudo dd if=$sdmountpoint of=SYSPartition.img skip=557056 count=3145728
echo "Done! Press enter."
read
}

backupbootpart() {
clear
echo "Dumping the Boot partition..."
dd if=$sdmountpoint of=BOOTPartition.img skip=49152 count=24576
echo "Done! Press enter."
read
}

flashsyspart() {
clear
echo "Flashing the System partition..."
dd if=$sdmountpoint of=SYSPartition.img bs=512 obs=512 seek=557056
echo "Done! Press enter."
read
}

flashbootpart() {
clear
echo "Flashing the Boot partition..."
dd if=$sdmountpoint of=BOOTPartition.img bs=512 obs=512 seek=49152
echo "Done! Press enter."
read

}

instprogs() {
clear

}

enableadbandroot() {
echo "Enabeling ADB and Root"
echo "Mounting Sys"
mountsyspart
echo "Rooting"

cat $dir/progsandroot/busybox > $sysmountpoint/system/bin/busybox
chown 0.1000 $sysmountpoint/system/bin/busybox
chmod 0755 $sysmountpoint/system/bin/busybox

cat $dir/progsandroot/su > $sysmountpoint/system/xbin/su
cat $dir/progsandroot/su > $sysmountpoint/system/xbin/daemonsu
cat $dir/progsandroot/su > $sysmountpoint/system/xbin/sugote
cat $sysmountpoint/system/bin/sh > $sysmountpoint/system/xbin/sugote-mksh
chown 0.0 $sysmountpoint/system/xbin/su
chmod 6755 $sysmountpoint/system/xbin/su
chown 0.0 $sysmountpoint/system/xbin/sugote
chmod 0755 $sysmountpoint/system/xbin/sugote
chown 0.0 $sysmountpoint/system/xbin/sugote-mksh
chmod 0755 $sysmountpoint/system/xbin/sugote-mksh
chown 0.0 $sysmountpoint/system/xbin/daemonsu
chmod 0755 $sysmountpoint/system/xbin/daemonsu

echo "Installing SuperSU"
cp $dir/progsandroot/supersu.apk $sysmountpoint/system/app/supersu.apk
echo "Enabeling ADB"
echo "Patching build.prop..."
sed -i -e 's/persist.sys.usb.config=mtp/persist.sys.usb.config=mtp,adb/g' $sysmountpoint/system/build.prop
sed -i -e 's/persist.service.adb.enable=0/persist.service.adb.enable=1/g' $sysmountpoint/system/build.prop
echo persist.service.debuggable=1 >> $sysmountpoint/system/build.prop
echo "Done!"
umountsys
}
 
mountsys() {
clear
echo "1) Mount"
echo "2) Unmount"
read -p [?]: val
if [ $val = "1" ]
then
mountsyspart
echo "Mounted at $sysmountpoint/system"
echo "Press Enter"
read
fi
if [ $val = "2" ]
then
sudo umount $sysmountpoint/system
fi
}

mountsyspart() {
mkdir $sysmountpoint/system
sudo mount -o loop -t ext4 SYSPartition.img $sysmountpoint/system
}

umountsys() {
umount $sysmountpoint/system
}
doallforme() {
return
}

mainmenu
