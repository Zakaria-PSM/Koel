#!/bin/bash

#Installation of necessary tools and updates

function inst (){
	
#Fast update system before installing tools
sudo apt update -y

#Install sshpass
sudo dpkg --configure -a
sudo apt -y install sshpass

#Install git
sudo apt-get -y install git

#Download Nipe
git clone https://github.com/htrgouvea/nipe && cd nipe

#Install libs and dependencies
yes | sudo cpan install Try::Tiny Config::Simple JSON

#Nipe must be run as root
sudo perl nipe.pl install


}

inst 

#Function to start nipe and become anonymous 

function nipeOn(){

#Change directory into the nipe folder
cd nipe


#Status if you are anonymous or not	
status_now=$(sudo perl nipe.pl status | grep 'Status'| awk -F: '{print$2}' | awk '{ gsub(/ /,""); print }')


#Check status of anonyminity 

if [ "$status_now" == "activated." ]
then 
	echo 'You are now anonymous'
	
else 
	#Start nipe
	country_code=$(curl ifconfig.io/country_code)
	echo "$country_code"

	sudo perl nipe.pl start
	sudo perl nipe.pl status
	sudo perl nipe.pl restart
	sudo perl nipe.pl status
	if [ $(curl ifconfig.io/country_code) != "$country_code" ]
	then 
		echo 'You are Anonymous'
	else 
		while [ $(curl ifconfig.io/country_code) == "$country_code" ]
		do
		  sudo perl nipe.pl restart
		done
	fi
	 
fi

curl ifconfig.io/country_code



}

nipeOn

#Connect to a remote server and do namp and masscan 
function connect(){
	
echo 'Please enter the ip / domain'
read ip_add 
echo "$ip_add"

echo 'Please enter the user'
read user_name
echo "$user_name"

echo 'Please enter the password'
read ps
echo "$ps"


 
#SSHPass into a remote server and do a nmap and masscan
sshpass -p "$ps" ssh "$user_name"@"$ip_add" 'sudo apt-get -y install nmap;sudo apt-get -y install masscan;mkdir report;echo "Enter target to be scanned";read tar_ip;sudo nmap "$tar_ip" -oG output.scan;cp /root/output.scan /root/report/output.scan;masscan "$tar_ip" -p 20-80 --rate 10000 >>./report/masscan_output.txt'
sshpass -p "$ps" scp -r "$user_name"@"$ip_add":/root/report/ ~/Desktop/
sshpass -p "$ps" ssh "$user_name"@"$ip_add" 'rm -rf report;rm output.scan'	
	
	
}

connect 

