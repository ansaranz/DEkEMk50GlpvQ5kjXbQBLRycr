#!/bin/bash

# Periodic Maitenance Report 2018
# Updated disk function on 28th Jan
# Corrected uptime function on 15thfeb

DATE=$(date +%d%b%Y)
PM_REPORT=/tmp/$DATE-pm-report
touch $PM_REPORT
touch /tmp/VARIABLE_ONE
touch /tmp/VARIABLE_TWO
touch /tmp/VARIABLE_THREE

RED='\033[0;31m'
GREEN='\033[0;32m'
U_L='\e[4m'
NC='\033[0m'
#echo -e "\e[4m Hello \e[0m"
#"\e[4m Hello \e[om"

ntp_refine()
{
>/tmp/VARIABLE_ONE
>/tmp/VARIABLE_TWO
>/tmp/VARIABLE_THREE
# STR="eeeeeee"; printf 'ddd %22s%-11s dddd \n'
printf "%-30s %-5s %-15s \n" "Hostname" "|" "NTP Server IP" > /tmp/VARIABLE_ONE
printf "%-30s %-5s %-15s \n" "--------" "|" "-------------" >> /tmp/VARIABLE_ONE
for i in $(cat list); do 
        NTP_YES=$(cat extracted/$i | grep -A15 "NTP Service Info" | grep -c "Ntp Configured in the server" )
        NTP_SERVICE=$(cat extracted/$i | grep -A15 "NTP Service Info" | grep  "Ntp Configured in the server" | awk '{print $1}' )

	if [ $NTP_YES == 1 ]; then
	
		if [ $NTP_SERVICE == CHRONYD ]; then

		IP_NTP_SERVER=$(cat extracted/$i | grep -A15 "NTP Service Info"  | grep "Reference ID" | awk '{print $5}' | cut -d'(' -f2 | cut -d')' -f1)
		printf "%-30s %-5s %-15s \n" "$i" "|" "$IP_NTP_SERVER" >> /tmp/VARIABLE_ONE

		elif [ $NTP_SERVICE == NTPD ]; then

		IP_NTP_SERVER=$(cat extracted/$i | grep -A15 "NTP Service Info" | grep -i "synchronised to NTP server" | awk '{print $5}' | cut -d'(' -f2 | cut -d ')' -f1)
                printf "%-30s %-5s %-15s \n" "$i" "|" "$IP_NTP_SERVER" >> /tmp/VARIABLE_ONE
		fi
		fi


        NTP_NO=$(cat extracted/$i | grep -A15 "NTP Service Info" | grep -c "Ntp service not configured in the server")
	if [ $NTP_NO == 1  ]; then
	echo $i >> /tmp/VARIABLE_TWO;
	fi
done

[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"Ntp configured in : \n$NC$GREEN$(cat /tmp/VARIABLE_ONE)$NC"
[ -s /tmp/VARIABLE_TWO ] && echo -e ""$U_L"Ntp not configured in : \n$NC$RED$(cat /tmp/VARIABLE_TWO)$NC"

}


disk_refine()
{
>/tmp/VARIABLE_ONE
>/tmp/VARIABLE_TWO
for i in $(cat list); do 
	if [ $(grep -c "Disk usage is normal"  extracted/$i) -eq 1 ]; then
	   echo $i >> /tmp/VARIABLE_ONE
	fi
	if [ $(grep -c "Disk usage Critical" extracted/$i) -ge 1 ]; then
	   echo  $i "\n" ------ >> /tmp/VARIABLE_TWO
	   grep "Disk usage Critical" extracted/$i | cut -d':' -f2,3 | cut -d':' -f2  >> /tmp/VARIABLE_TWO
	fi
done
#echo -e "\e[4m Hello \e[0m"
#[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"Disk Usage normal in following servers:\n$NC$GREEN$(cat /tmp/VARIABLE_ONE)$NC"
[ -s /tmp/VARIABLE_TWO ] && echo -e ""$U_L"Disk Usage critical in following servers:\n$NC$RED$(cat /tmp/VARIABLE_TWO)$NC" || echo -e "$GREEN Disk usage is normal in all servers $NC"
}

memory_refine()
{
>/tmp/VARIABLE_ONE
for i in $(cat list); do
        MEM_AVAILABLE6=$(egrep -A5 "Memory Usage" extracted/$i | grep "buffers/cache" | awk '{print $4}')
	MEM_AVAILABLE7=$(egrep -A5 "Memory Usage" extracted/$i | awk '{print $6}' | grep [0-9])
	MEM_TOTAL=$(egrep -A5 "Memory Usage" extracted/$i | grep "Mem:" | awk '{print $2}')
[[ -n $MEM_AVAILABLE6 ]] && MEM_PERC_AVAIL=$(bc -l <<< "($MEM_AVAILABLE6 / $MEM_TOTAL) * 100") || MEM_PERC_AVAIL=$(bc -l <<< "($MEM_AVAILABLE7 / $MEM_TOTAL) * 100")
	PERC_ROUNDED=$(printf "%.0f" "$MEM_PERC_AVAIL")
        if [ $PERC_ROUNDED -lt 20 ]; then
           echo "$i     -       $PERC_ROUNDED" >> /tmp/VARIABLE_ONE
        fi
done

[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"Available memory in following servers noted as below 20 percentage : \n$NC$RED$(cat /tmp/VARIABLE_ONE)$NC" || echo -e "$GREEN Memory usage of all servers noted as normal $NC"
}


load_refine()
{
>/tmp/VARIABLE_ONE
for i in $(cat list); do
        CPU_NUM=$(egrep "Number of CPUs" extracted/$i | awk '{print $5}')
        L1=$(egrep "load average" extracted/$i | awk '{print $8,$9,$10,$11,$12}' | cut -d':' -f2| cut -d',' -f1 )
	L2=$(egrep "load average" extracted/$i | awk '{print $8,$9,$10,$11,$12}' | cut -d':' -f2| cut -d',' -f2 )
	L3=$(egrep "load average" extracted/$i | awk '{print $8,$9,$10,$11,$12}' | cut -d':' -f2| cut -d',' -f3 )
        if [[ "$L1|$L2|$L3" > $CPU_NUM ]]; then
           echo "$i     -       $L1,$L2,$L3" >> /tmp/VARIABLE_ONE
        fi
done

[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"Load hike found in following servers : \n$NC$RED$(cat /tmp/VARIABLE_ONE)$NC" || echo -e "$GREEN Load in normal in all servers $NC"
}

selinux_refine()
{
>/tmp/VARIABLE_ONE
>/tmp/VARIABLE_TWO
for i in $(cat list); do 
        if [ $(grep "SELinux status"  extracted/$i | grep -c "enabled") -eq 1 ]; then
           echo $i >> /tmp/VARIABLE_ONE
        fi
        if [ $(grep "SELinux status" extracted/$i | grep -c "disabled") -eq 1 ]; then
           echo $i >> /tmp/VARIABLE_TWO
        fi
done
#[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"SELinux enabled in following servers: \n$NC$GREEN$(cat /tmp/VARIABLE_ONE)$NC"
[ -s /tmp/VARIABLE_TWO ] && echo -e ""$U_L"SELinux disabled in following servers: \n$NC$RED$(cat /tmp/VARIABLE_TWO)$NC" || echo -e "$GREEN SELinux is enabled in all servers $NC"
}

iptables_refine()
{
>/tmp/VARIABLE_ONE
>/tmp/VARIABLE_TWO
for i in $(cat list); do

FLAG_IPTABLES=$(sed -n -e '/Firewall Rules/,/Network Errors/p' extracted/$i | egrep -c "REJECT|ACCEPT")
#FLAG_IPTABLES=$(sed -n -e '/Firewall Rules/,/Network Errors/p' extracted/$i | wc -l)
	if [ "$FLAG_IPTABLES" -gt "3" ]; then
           echo $i >> /tmp/VARIABLE_ONE
        else
           echo $i >> /tmp/VARIABLE_TWO
        fi
done
#[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"IPTABLES Configured in following servers: \n$NC$GREEN$(cat /tmp/VARIABLE_ONE)$NC"
[ -s /tmp/VARIABLE_TWO ] && echo -e ""$U_L"IPTABLES not Configured in following servers: \n$NC$RED$(cat /tmp/VARIABLE_TWO)$NC"  || echo -e "$GREEN IPTABLES configured in all servers $NC"
}

rhn_refine()
{
>/tmp/VARIABLE_ONE
>/tmp/VARIABLE_TWO
for i in $(cat list); do 
        if [ $(grep -c "System has a Valid RedHat registration"  extracted/$i) -eq 1 ]; then
           echo $i >> /tmp/VARIABLE_ONE
        fi
        if [ $(grep -c "Not Registered with RedHat !!!" extracted/$i) -eq 1 ]; then
           echo $i >> /tmp/VARIABLE_TWO
        fi
done
[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"Systems Registered with RedHat: \n$NC$GREEN$(cat /tmp/VARIABLE_ONE)$NC"
[ -s /tmp/VARIABLE_TWO ] && echo -e ""$U_L"Systems Not Registered: \n$NC$RED$(cat /tmp/VARIABLE_TWO)$NC" || echo -e "$GREEN All Systems Registered with RedHat $NC"
}

uptime_refine()
{
>/tmp/VARIABLE_ONE
>/tmp/VARIABLE_TWO
for i in $(cat list); do
	if [ $(grep "Uptime"  extracted/$i | grep -c days) == 1 ]; then
	UP_DAYS=$(grep "Uptime"  extracted/$i | awk '{print $3}')
         	if [ $UP_DAYS -gt 60 ]; then
           		echo "$i	-	$UP_DAYS Days" >> /tmp/VARIABLE_TWO
		else 
			echo "$i        -       $UP_DAYS Days" >> /tmp/VARIABLE_ONE
        	fi
	else 
		echo "$i        -       $(grep "Uptime"  extracted/$i | awk '{print $3}')" >> /tmp/VARIABLE_ONE
	fi
		
done

[ -s /tmp/VARIABLE_ONE ] && echo -e ""$U_L"Uptime of following servers noted as below 60 days: \n$NC$RED$(cat /tmp/VARIABLE_ONE)$NC" || echo -e "$GREEN Uptime of all servers is noted as above 60 days$NC"
}




######################################################################################################################

{
echo -e "\t\t\t==========---  +++  PERIODIC MAITENANCE REPORT  +++  ---==========\n"

#NTP 
echo -e "\t\t\t==========---\t\t    NTP  \t\t  ---==========\n"
ntp_refine;

#Disk
echo -e "\t\t\t==========---\t\t    Disk Usage  \t\t  ---==========\n"
disk_refine;

#Memory
echo -e "\t\t\t==========---\t\t    Memory Usage  \t\t  ---==========\n"
memory_refine;

#Load
echo -e "\t\t\t==========---\t\t    Load   \t\t  ---==========\n"
load_refine;

#SELinux
echo -e "\t\t\t==========---\t\t    SELINUX  \t\t  ---==========\n"
selinux_refine;

#IPTables
echo -e "\t\t\t==========---\t\t    IPTABLES  \t\t  ---==========\n"
iptables_refine;

#RHN Network Check
echo -e "\t\t\t==========---\t\t    RHN  \t\t  ---==========\n"
rhn_refine;

#Uptime
echo -e "\t\t\t==========---\t\t    UPTIME  \t\t  ---==========\n"
uptime_refine;

#Logs
echo -e 'Check Logs: \n for i in $(cat list); do echo -e ---------/$i---------;cat extracted/$i | egrep -A100 "Message Log"; done   | more '

} >> "$PM_REPORT"

more "$PM_REPORT"

rm /tmp/VARIABLE_ONE
rm /tmp/VARIABLE_TWO
rm /tmp/VARIABLE_THREE
rm "$PM_REPORT"

exit 0

