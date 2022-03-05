#!/usr/bin/env bash
## Author: Michael Ramsey
## Objective Find A cPanel Users Domlogs Stats for last 5 days for all of their domains.
## https://gitlab.com/cpaneltoolsnscripts/cPanelSnapshot-by-cpanel-user
## How to use.
# ./cPanelSnapshotBycPanelUser.sh username
#./cPanelSnapshotcPanelUser.sh exampleuserbob
#
##bash <(curl https://gitlab.com/cpaneltoolsnscripts/cPanelSnapshot-by-cpanel-user/raw/master/cPanelSnapshotBycPanelUser.sh || wget -O - https://gitlab.com/cpaneltoolsnscripts/cPanelSnapshot-by-cpanel-user/raw/master/cPanelSnapshotBycPanelUser.sh) exampleuserbob;
##
Username=$1

#Allow users to see full domlog paths
FullDomlogPathToggle=$2

#CURRENTDATE=$(date +"%Y-%m-%d %T") # 2019-02-09 06:47:56
#PreviousDay1=$(date --date='1 day ago' +"%Y-%m-%d")  # 2019-02-08
#PreviousDay2=$(date --date='2 days ago' +"%Y-%m-%d") # 2019-02-07
#PreviousDay3=$(date --date='3 days ago' +"%Y-%m-%d") # 2019-02-06
#PreviousDay4=$(date --date='4 days ago' +"%Y-%m-%d") # 2019-02-05

#datetimeDom=$(date +"%d/%b/%Y") # 09/Feb/2019
#datetimeDom1DaysAgo=$(date --date='1 day ago' +"%d/%b/%Y")  # 08/Feb/2019
#datetimeDom2DaysAgo=$(date --date='2 days ago' +"%d/%b/%Y") # 07/Feb/2019
#datetimeDom3DaysAgo=$(date --date='3 days ago' +"%d/%b/%Y") # 06/Feb/2019
#datetimeDom4DaysAgo=$(date --date='4 days ago' +"%d/%b/%Y") # 05/Feb/2019

declare -a datetimeDomLast5_array=($(date +"%d/%b/%Y") $(date --date='1 day ago' +"%d/%b/%Y") $(date --date='2 days ago' +"%d/%b/%Y") $(date --date='3 days ago' +"%d/%b/%Y") $(date --date='4 days ago' +"%d/%b/%Y")); #for DATE in "${datetimeDomLast5_array[@]}"; do echo $DATE; done;

datetimeDcpumon=$(date +"%Y/%b/%d") # 2019/Feb/15
#datetimeDcpumon1DaysAgo=$(date --date='1 day ago' +"%Y/%b/%d")  # 2019/Feb/14
#datetimeDcpumon2DaysAgo=$(date --date='2 days ago' +"%Y/%b/%d") # 2019/Feb/13
#datetimeDcpumon3DaysAgo=$(date --date='3 days ago' +"%Y/%b/%d") # 2019/Feb/12
#datetimeDcpumon4DaysAgo=$(date --date='4 days ago' +"%Y/%b/%d") # 2019/Feb/11

#Current Dcpumon file
DcpumonCurrentLOG="/var/log/dcpumon/${datetimeDcpumon}" # /var/log/dcpumon/2019/Feb/15

declare -a datetimeDcpumonLast5_array=($(date +"%Y/%b/%d") $(date --date='1 day ago' +"%Y/%b/%d") $(date --date='2 days ago' +"%Y/%b/%d") $(date --date='3 days ago' +"%Y/%b/%d") $(date --date='4 days ago' +"%Y/%b/%d")); #for DATE in "${datetimeDcpumonLast5_array[@]}"; do echo $DATE; done;


#user_homedir=$(sudo egrep "^${Username}:" /etc/passwd | cut -d: -f6)

Now=$(date +"%Y-%m-%d_%T")

user_cPanelSnapshot="${Username}-cPanelSnapshot_${Now}.txt";

#create logfile in user's homedirectory.
#sudo touch "$user_cPanelSnapshot"

#chown logfile to user
#sudo chown ${Username}:${Username} "$user_cPanelSnapshot";


main_function() {

#if sudo bash -c "[[ -f ${DcpumonCurrentLOG} ]]"; then
  	for DATE in "${datetimeDcpumonLast5_array[@]}"; do 
	echo "=============================================================";
	echo "Find $Username user's highest CPU use processes via Dcpumon Logs for $DATE";
	sudo grep "$Username" /var/log/dcpumon/"${DATE}";
	done; echo "";
	echo "For more information about Dcpumon(Daily Process Logs) see https://docs.cpanel.net/whm/server-status/daily-process-log/82/"
	echo "=============================================================" 
#	echo "";
#	else
   	#echo "The DcpumonCurrentLOG '$DcpumonCurrentLOG' was not found. Not running Dcpumon stats" 
#	echo "";
#	fi
echo ""
echo "Web Traffic Stats Check";
#if [ "${FullDomlogPathToggle}" != 'f' -o "${FullDomlogPathToggle}" != 'y' ] ;

#then 
#        echo "View Apache requests per day for cPanel $Username";
#        sudo find /usr/local/apache/domlogs/"$Username" -type f -exec awk '{print $4}' {} +| cut -d: -f1|sort | uniq -c
            
#fi
echo "";
for DATE in "${datetimeDomLast5_array[@]}"; do
echo "=============================================================";
echo "Apache Dom Logs POST Requests for ${DATE} for $Username";
if [ "${FullDomlogPathToggle}" == 'f' -o "${FullDomlogPathToggle}" == 'y' ] ;then

	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep POST | awk '{print $1}' | cut -d: -f1| sort | uniq -c | sort -rn | head
	echo ""
	echo "Apache Dom Logs GET Requests for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep GET | awk '{print $1}' | cut -d: -f1 | sort | uniq -c | sort -rn | head
	echo ""
	echo "Apache Dom Logs Top 10 bot/crawler requests per domain name for ${DATE}"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -Ei 'crawl|bot|spider|yahoo|bing|google'| awk '{print $1}' | cut -d: -f1| sort | uniq -c | sort -rn | head
	echo ""
	echo "Apache Dom Logs top ten IPs for ${DATE} for $Username"

	command=$(sudo grep -r "$DATE" /usr/local/apache/domlogs/"${Username}" | grep POST | awk '{print $1}' |sed -e 's/^[^=:]*[=:]//' -e 's|"||g' | sort | uniq -c | sort -rn | head);readarray -t iparray < <( echo "${command}" | tr '/' '\n'); echo ""; for IP in "${iparray[@]}"; do echo "$IP"; done; echo ""; echo "Show unique IP's with whois IP, Country,and ISP"; echo ""; for IP in "${iparray[@]}"; do IP=$(echo "$IP" |grep -Eo '([0-9]{1,3}[.]){3}[0-9]{1,3}|(*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:)))(%.+)?\s*)'); whois -h whois.cymru.com " -c -p $IP"|cut -d"|" -f 2,4,5|grep -Ev 'IP|whois.cymru.com'; done

	echo ""
	echo "Checking the IPs that Have Hit the Server Most and What Site they were hitting:"
	grep -rs "$DATE" /usr/local/apache/domlogs/"$Username" | awk {'print $1'} | sort | uniq -c | sort -n | tail -10| sort -rn| column -t
	echo ""
	echo "Checking the Top Hits Per Site Per IP:"
	grep -rs "$DATE" /usr/local/apache/domlogs/"$Username" | awk {'print $1,$6,$7'} | sort | uniq -c | sort -n | tail -15| sort -rn| column -t
	echo ""
	echo "Apache Dom Logs find the top number of uri's being requested for ${DATE}"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep POST | awk '{print $7}' | cut -d: -f2 | sort | uniq -c | sort -rn | head
	echo ""
	echo "";
	echo "View Apache requests per hour for cPanel $Username";
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | cut -d[ -f2 | cut -d] -f1 | awk -F: '{print $2":00"}' | sort -n | uniq -c
	echo ""
	echo "CMS Checks"
	echo ""
	echo "Wordpress Checks"
	echo "Wordpress Login Bruteforcing checks for wp-login.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "wp-login.php|wp-admin.php" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Wordpress Cron wp-cron.php(virtual cron) checks for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep wp-cron.php| cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Wordpress XMLRPC Attacks checks for xmlrpc.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep xmlrpc.php| cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Wordpress Heartbeat API checks for admin-ajax.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep admin-ajax.php| cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn;
	echo ""
	echo "CMS Bruteforce Checks"
	echo "Drupal Login Bruteforcing checks for user/login/ for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "user/login/" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Magento Login Bruteforcing checks for admin pages /admin_xxxxx/admin/index/index for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "admin_[a-zA-Z0-9_]*[/admin/index/index]" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Joomla Login Bruteforcing checks for admin pages /administrator/index.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "admin_[a-zA-Z0-9_]*[/admin/index/index]" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "vBulletin Login Bruteforcing checks for admin pages admincp for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "admincp" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Opencart Login Bruteforcing checks for admin pages /admin/index.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "/admin/index.php" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Prestashop Login Bruteforcing checks for admin pages /adminxxxx /admin123 for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "/admin[a-zA-Z0-9_]*$" | cut -f 1 -d ":" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""

else
		sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep POST | awk '{print $1}' | cut -d: -f1 |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"| sort | uniq -c | sort -rn | head
	echo ""
	echo "Apache Dom Logs GET Requests for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep GET | awk '{print $1}' | cut -d: -f1 |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" | sort | uniq -c | sort -rn | head
	echo ""
	echo "Apache Dom Logs Top 10 bot/crawler requests per domain name for ${DATE}"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -Ei 'crawl|bot|spider|yahoo|bing|google'| awk '{print $1}' | cut -d: -f1 |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"| sort | uniq -c | sort -rn | head
	echo ""
	echo "Apache Dom Logs top ten IPs for ${DATE} for $Username"

	command=$(sudo grep -r "$DATE" /usr/local/apache/domlogs/"${Username}" | grep POST | awk '{print $1}' | sed -e 's/^[^=:]*[=:]//' -e 's|"||g' | sort | uniq -c | sort -rn | head);readarray -t iparray < <( echo "${command}" | tr '/' '\n'); echo ""; for IP in "${iparray[@]}"; do echo "$IP"; done; echo ""; echo "Show unique IP's with whois IP, Country,and ISP"; echo ""; for IP in "${iparray[@]}"; do IP=$(echo "$IP" |grep -Eo '([0-9]{1,3}[.]){3}[0-9]{1,3}|(*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:)))(%.+)?\s*)'); whois -h whois.cymru.com " -c -p $IP"|cut -d"|" -f 2,4,5|grep -Ev 'IP|whois.cymru.com'; done

	echo ""
	echo "Checking the IPs that Have Hit the Server Most and What Site they were hitting:"
	grep -rs "$DATE" /usr/local/apache/domlogs/"$Username" | awk {'print $1'} |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" | sort | uniq -c | sort -n | tail -10| sort -rn| column -t
	echo ""
	echo "Checking the Top Hits Per Site Per IP:"
	grep -rs "$DATE" /usr/local/apache/domlogs/"$Username" | awk {'print $1,$6,$7'} |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" | sort | uniq -c | sort -n | tail -15| sort -rn| column -t
	echo ""
	echo "Apache Dom Logs find the top number of uri's being requested for ${DATE}"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep POST | awk '{print $7}' | cut -d: -f2 |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" | sort | uniq -c | sort -rn | head
	echo ""
	echo "";
	echo "View Apache requests per hour for cPanel $Username";
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | cut -d[ -f2 | cut -d] -f1 | awk -F: '{print $2":00"}' | sort -n | uniq -c
	echo ""
	echo "CMS Checks"
	echo ""
	echo "Wordpress Checks"
	echo "Wordpress Login Bruteforcing checks for wp-login.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "wp-login.php|wp-admin.php" | cut -f 1 -d ":" | sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Wordpress Cron wp-cron.php(virtual cron) checks for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep wp-cron.php| cut -f 1 -d ":" | sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Wordpress XMLRPC Attacks checks for xmlrpc.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep xmlrpc.php| cut -f 1 -d ":" | sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Wordpress Heartbeat API checks for admin-ajax.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep admin-ajax.php| cut -f 1 -d ":" | sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g" |awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn;
	echo ""
	echo "CMS Bruteforce Checks"
	echo "Drupal Login Bruteforcing checks for user/login/ for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "user/login/" | cut -f 1 -d ":" |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"|awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Magento Login Bruteforcing checks for admin pages /admin_xxxxx/admin/index/index for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "admin_[a-zA-Z0-9_]*[/admin/index/index]" | cut -f 1 -d ":" |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"|awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Joomla Login Bruteforcing checks for admin pages /administrator/index.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "admin_[a-zA-Z0-9_]*[/admin/index/index]" | cut -f 1 -d ":" |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"|awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "vBulletin Login Bruteforcing checks for admin pages admincp for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "admincp" | cut -f 1 -d ":" |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"|awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Opencart Login Bruteforcing checks for admin pages /admin/index.php for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "/admin/index.php" | cut -f 1 -d ":" |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"|awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""
	echo "Prestashop Login Bruteforcing checks for admin pages /adminxxxx /xxxxadmin for ${DATE} for $Username"
	sudo grep -r "$DATE" /usr/local/apache/domlogs/"$Username" | grep -E "/admin[a-zA-Z0-9_]*$" | cut -f 1 -d ":" |sed 's|/usr/local/apache/domlogs/||g'|sed 's|-ssl_log||g' |sed "s|$Username/||g"|awk {'print $1,$6,$7'}  | sort | uniq -c | sort -n|tail| sort -rn
	echo ""


fi
done;
echo "============================================================="
echo "Contents have been saved to ${user_cPanelSnapshot}"
}

# log everything, but also output to stdout
main_function 2>&1 | tee -a "${user_cPanelSnapshot}"

