#!/bin/bash

#UBUNTU
#Directory for RHC detail collection
mkdir /root/kn-hcs-"$(hostname)" && cd /root/kn-hcs-"$(hostname)" && pwd
hostname >> hostname

###########################

echo "-----------3.1.Checking Server-Hardware---------"

echo "-----------3.1.1"
dmidecode >> dmidecode
dmidecode | grep -A3 "System Information" >> systemdmi_info
dmidecode | grep -A3 "BIOS Information" >> systemdmi_info
dmidecode | grep -A50 "Processor Information"  | egrep "Processor Information|Manufacturer:|Family:|Version:" >> systemdmi_info

echo "-----------3.1.3"
fdisk -l >> fdisk-l
#multipath -ll >> multipath-ll
which multipath >/dev/null; if [ $? -eq 0 ]; then multipath -ll >> multipath-ll; else echo "multipth not configured" >> multipath_status; fi

echo "-----------3.1.4"
free -m >> free-m
free -g >> free-g
free -g | grep "Mem" | awk '{print $2}' >> ram_in_gb
vmstat >> vmstat
vmstat  -s -S m >> vmstat-ss

###########################

echo "-----------3.2.Checking Installed-Software---------"

echo "-----------3.2.1"
cp -v /etc/issue .


echo "-----------3.2.2"
uname -a > uname-a
[ -f /etc/default/grub ] && cp -v /etc/default/grub .
#[ -f /etc/modprobe.conf ] && cp -v /etc/modprobe.conf .
lsmod >> lsmod
cp -v /proc/sys/kernel/tainted .

echo "-----------3.2.3"
apt list --installed >> apt_list
dpkg --list >> dpkg_list
cp -v /etc/apt/sources.list .
apt-cache stats >> apt-cache_stats
apt-get -s upgrade  >> apt-get_upgrade
apt-get -s dist-upgrade >> apt-get_dist-upgrade


###########################

echo "-----------3.3.Checking SSH and Access details--------"

echo "-----------3.3.1"
cp -v /etc/ssh/ssh_config .

echo "-----------3.3.2"
cp -v /etc/sudoers .

###########################

echo "-----------3.4.Checking Storage-Configurations --------"

echo "-----------3.4.1"
lsblk -l > lsblk
blkid > blkid
lsscsi -v > lsscsi-v
cat /proc/scsi/scsi >> proc-scsi

echo "-----------3.4.2"
parted --list >> parted-list
sfdisk -l >> sfdisk-l
dmesg | grep -i "attached" >> Storage-disks
ls -l /dev/disk/by-path/ >> disk-by-path
#cp -v /etc/multipath.conf .

echo "-----------3.4.3"
mount > mount 2>&1
vgdisplay > vgdisplay 2>&1
lvdisplay > lvdisplay 2>&1

echo "-----------3.4.4"
df -hT >> df-hT
df -i >> df-i

echo "-----------3.4.5"
cp -v /etc/fstab .

###########################

echo "-----------3.5.Checking Network-Configuration --------"

echo "-----------3.5.1"
ifconfig -a >> ifconfig-a
ip a >> ip-a
VL=$(ifconfig | grep "Link encap" | grep -v lo| awk '{print $1}');echo Interfaces:"$VL"; for i in $VL;do ethtool "$i" >> ethtool-"$i";ip -s link show $i >> link-status-$i; done

#ethtool eth0 > ethtool-eth0

echo "-----------3.5.2"
arp -e >> arp-e
netstat -r >> netstat-r
netstat -i >> netstat-i
netstat -s >> netstat-s
netstat -ulnp >> netstat-ulnp
netstat -tlnp >> netstat-tlnp
netstat -ntulp >> netstat-ntulp

echo "-----------3.5.2"
cat /proc/net/dev >> proc-net-dev
route >> route
ip route show | grep default >> route-def
ip link show >> ip-link-show

echo "-----------3.5.3"
lsof >> lsof
cp -v /etc/network/interfaces .

###########################
echo "-----------3.6.Checking Network-Services --------"
systemctl list-unit-files >> systemctl_all
systemctl list-units >> systemctl_list-units
service --status-all >> service_status-all

echo "-----------3.6.2"
date >> date
hwclock >> hwclock
timedatectl status >> timedatectl_status
ntpstat >> ntpstat
ntpq -p >> ntpq-p

cp -v /etc/ntp.conf .

echo "-----------3.6.3"
grep -i crashkernel /boot/grub/grub.cfg >> kdump
[ -f /etc/default/kdump-tools ] && cp -v /etc/default/kdump-tools .

echo "-----------3.6.4"
cp -v /etc/rsyslog.conf .

###########################
echo "-----------3.7.Checking Kernel-Parameters --------"

echo "-----------3.7.1"
grep Hugepagesize /proc/meminfo >> hugepagesize
cat /proc/meminfo >> meminfo

echo "-----------3.7.2"
cp -v /etc/sysctl.conf .

echo "-----------3.7.3"
cp -v /boot/grub/grub.cfg .

###########################
echo "-----------3.8.Checking Security-Parameters --------"

echo "-----------3.8.2"
iptables -L >> iptables-L


echo "-----------3.8.3"
cp -v /etc/hosts.allow .
cp -v /etc/hosts.deny .


###########################

echo "-----------3.10.Checking Performance --------"

echo "-----------3.10.1"
uptime >> uptime

echo "-----------3.10.2"
df -h >>df-h
df -i >>df-i

echo "-----------3.10.3"
sar -u 1 3 >> sar-cpu
sar -P ALL 1 1 >> sar-cpu-proc
sar -q 3 3 >> sar-cpu-load
sar -r 1 3 >> sar-memory
#sar -S 1 3 >> sar-memory-swap
sar -b 1 3 >> sar-io
sar -p -d 1 1 >> sar-disk
sar -n DEV 1 1 >> sar-network-DEV
sar -n ALL 3 3 >> sar-network-ALL
cp -rv /var/log/sa .

echo "-----------3.10.4"
egrep -i 'failed|error|invalid|warning' /var/log/auth.log* >> secure-failed
egrep -i 'failed|error|memory|invalid' /var/log/syslog* >> syslog-failed
cp -v /var/log/syslog .
cp -v /var/log/auth.log .
cp -v /var/log/dmesg .

echo "-----------3.10.5"
lscpu >> lscpu

echo "-----------3.10.6"
cp -rv /var/spool/cron .
cp -rv /etc/cron* .
###########################
cd /root
tar -cvzf kn-hcs-`hostname`.tgz kn-hcs-`hostname`

exit 0
