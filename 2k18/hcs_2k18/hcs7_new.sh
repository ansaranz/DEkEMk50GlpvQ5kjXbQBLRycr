#!/bin/bash

#RHEL 7
#Directory for RHC detail collection
mkdir /root/kn-hcs-"$(hostname)" && cd /root/kn-hcs-"$(hostname)" && pwd
hostname >> hostname

###########################

echo "----------------------3.1.Checking Server-Hardware---------"

echo "-----------3.1.1"
dmidecode >> dmidecode
dmidecode | grep -A3 "System Information" >> systemdmi_info
dmidecode | grep -A3 "BIOS Information" >> systemdmi_info
dmidecode | grep -A50 "Processor Information"  | egrep "Processor Information|Manufacturer:|Family:|Version:" >> systemdmi_info

echo "-----------3.1.3"
fdisk -l >> fdisk-l
multipath -ll >> multipath-ll
#which multipath >/dev/null; if [ $? -eq 0 ]; then multipath -ll >> multipath-ll; else echo "multipth not configured" >> multipath_status; fi

echo "-----------3.1.4"
free -m >> free-m
free -g >> free-g
free -g | grep "Mem" | awk '{print $2}' >> ram_in_gb
vmstat >> vmstat
vmstat  -s -S m >> vmstat-ss

###########################

echo "----------------------3.2.Checking Installed-Software---------"

echo "-----------3.2.1"
cp -v /etc/redhat-release .
#cp -v /etc/oracle-release .

subscription-manager status >> subscription-manager-status 2>&1

echo "-----------3.2.2"
uname -a > uname-a
[ -f /etc/grub2.cfg ] && cp -v /etc/grub2.cfg .
[ -f /etc/grub.conf ] && cp -v /etc/grub.conf .
[ -f /etc/modprobe.conf ] && cp -v /etc/modprobe.conf .
lsmod >> lsmod
cp -v /proc/sys/kernel/tainted .

echo "-----------3.2.3"
rpm -qa >> rpm-qa
yum list >> yum-list 2>&1
yum grouplist > yum-grouplist 2>&1
yum info-security | grep Critical >> Critical-updates 2>&1
yum check-update > yum-check-update 2>&1
yum check-update --security > yum-check-update-security 2>&1
cp -rv /etc/yum.repos.d .

###########################

echo "----------------------3.3.Checking SSH and Access details--------"

echo "-----------3.3.1"
cp -v /etc/ssh/sshd_config .
grep -i PermitRootLogin /etc/ssh/sshd_config >> sshd_config_root_login
grep -i "Client*" /etc/ssh/sshd_config >> ssh_session_timeout

echo "-----------3.3.2"
cp -v /etc/pam.d/system-auth .
cp -v /etc/sudoers .

###########################

echo "----------------------3.4.Checking Storage-Configurations --------"

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
cp -v /etc/multipath.conf .

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

echo "----------------------3.5.Checking Network-Configuration --------"

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
ss -ntlp >> ss-ntlp

echo "-----------3.5.2"
cat /proc/net/dev >> proc-net-dev
route >> route
ip route show | grep default >> route-def
ip link show >> ip-link-show

echo "-----------3.5.3"
lsof >> lsof
cp -v /etc/sysconfig/network-scripts/ifcfg-* .

###########################
echo "----------------------3.6.Checking Network-Services --------"

echo "-----------3.6.1"
systemctl list-dependencies >> systemctl-list-dependencies
systemctl list-jobs >> systemctl-list-jobs
systemctl list-sockets >> systemctl-list-sockets
systemctl list-unit-files >> systemctl-list-unit-files
systemctl list-units >> systemctl-list-units
systemctl list-timers >> systemctl-list-timers

echo "-----------3.6.2"
date >> date
hwclock >> hwclock

systemctl status ntpdate.service >> ntpdate.service
systemctl status chronyd.service >> chronyd.service
ntpstat >> ntpstat
ntpq -p >> ntpq-p
cp -v /etc/ntp.conf .
cp /etc/chrony.conf .

echo "-----------3.6.3"
grep -i crashkernel /etc/grub.conf >> kdump

echo "-----------3.6.4"
cp -v /etc/syslog.conf .
cp -v /etc/rsyslog.conf .

###########################
echo "----------------------3.7.Checking Kernel-Parameters --------"

echo "-----------3.7.1"
grep Hugepagesize /proc/meminfo >> hugepagesize
cat /proc/meminfo >> meminfo

echo "-----------3.7.2"
cp -v /etc/sysctl.conf .

echo "-----------3.7.3"
cp -v /boot/grub/grub.conf .
grep -i elevator /etc/grub.conf >> io-scheduler

echo "-----------3.7.4"
grep -i nousb /etc/grub.conf >> target-security-policy

###########################
echo "----------------------3.8.Checking Security-Parameters --------"

echo "-----------3.8.1"
sestatus >> sestatus

echo "-----------3.8.2"
chkconfig --list >> chkconfig-list-all
chkconfig --list iptables >> iptables-chk
iptables -L >> iptables-L
cp -v /etc/sysconfig/iptables .

echo "-----------3.8.3"
cp -v /etc/hosts.allow .
cp -v /etc/hosts.deny .

systemctl status firewalld.service >> firewalld.service

###########################
echo "----------------------3.9.Checking Monitoring-and-Mangeability --------"

echo "-----------3.9.1"
echo "Sar utility Analyze"

echo "-----------3.9.2"
grep -i xmlrpc /etc/sysconfig/rhn/up2date >> rhn-server

echo "-----------3.9.3"
echo "Check if client has staging environment"

echo "-----------3.9.4"
echo "Check how the server backup policy"

###########################
echo "----------------------3.10.Checking Performance --------"

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
egrep -i 'failed|error|invalid|warning' /var/log/secure* >> secure-failed
egrep -i 'failed|error|memory|invalid' /var/log/messages* >> messages-failed
cp -v /var/log/messages .
cp -v /var/log/secure .
cp -v /var/log/dmesg .
cp -v /var/log/audit/audit.log .

echo "-----------3.10.5"
mpstat -P ALL >> mpstat-all
iostat -x >> iostat
lscpu >> lscpu

echo "-----------3.10.6"
cp -rv /var/spool/cron .
cp -rv /etc/cron* .
###########################
cd /root
tar -cvzf kn-hcs-`hostname`.tgz kn-hcs-`hostname`

exit 0
