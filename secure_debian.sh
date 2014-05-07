#!/bin/bash
#name: secure_debian.sh
#authors: mark spicer
#purpose: to lock down a debian based system for a blue team compitition

#make sure the user running this script is the root user
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#change root password
echo "changing the root password..."
passwd

#remove all non-default users
cat /etc/passwd | cut -d: -f1 > current-users.txt

#pull the necessary-users.txt file
wget https://raw.githubusercontent.com/lodge93/blueteam/master/necessary-users.txt

#compare the two user files and create an output file of users to remove
comm -23 <(sort current-users.txt) <(sort necessary-users.txt) > users-to-remove.txt

#remove users that were not in the necessary-users file
while read USER
do
	echo "removing user $USER"
	userdel -rf $USER
done <users-to-remove.txt

#add a new regular user
useradd blueteam
sudo blueteam
echo "changing the blueteam user password..."
passwd
exit

#lock down the sudoers file
echo "root    ALL=(ALL:ALL) ALL" > /etc/sudoers
chmod 000 /etc/sudoers
chattr +i /etc/sudoers

#clear cronjobs
echo "" > /etc/crontab
chattr +i /etc/crontab
echo "" > /etc/anacrontab
chattr +i /etc/anacrontab

##########check file repos
##########
##########update package manager
##########
##########Make Sure No Non-Root Accounts Have UID Set To 0
##########
##########find all no owner files
##########
##########Stop unwarrented processes
##########
##########disable unwarrented processes
##########
##########rebuild bin from source if there is time
##########
##########check open ports
##########
##########
