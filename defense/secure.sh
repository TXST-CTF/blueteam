#!/bin/bash
# Name: secure.sh
# Author: Mark Spicer
# Purpose: To secure a machine during a security competition.

# Verify this script is being run by the root user.
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Determine the OS and version on which the script is being run.
OS=$(lsb_release -si | awk '{print tolower($0)}')
echo $OS

VERSION=$(lsb_release -sc | awk '{print tolower($0)}')
echo $VERSION

# Temporarily configure DNS servers. 
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf

# Fix package repositories for each os. 
if [ $OS == 'ubuntu' ]; then
	# Fix file repositories
	mv /etc/apt/sources.list /etc/apt/sources.list.backup
	echo "deb http://mirrors.us.kernel.org/ubuntu/ $VERSION main" > /etc/apt/sources.list
	echo "deb-src http://mirrors.us.kernel.org/ubuntu/ $VERSION main" >> /etc/apt/sources.list
	echo "deb http://mirrors.us.kernel.org/ubuntu/ $VERSION-security main" >> /etc/apt/sources.list
    
    # Update apt-get with the new sources.
    apt-get update

	# Reinstall passwd command and change root password.
	apt-get --reinstall install -y passwd
	passwd

	# Reinstall crucial software.
	apt-get --reinstall install -y bash
	apt-get --reinstall install -y openssl
	apt-get --reinstall install -y coreutils
	apt-get --reinstall install -y vim
	apt-get --reinstall install -y wget
elif [ $OS == 'debian' ]; then
	# Fix file repositories
	mv /etc/apt/sources.list /etc/apt/sources.list.backup

    echo "deb http://http.debian.net/debian $VERSION main" > /etc/apt/sources.list
    echo "deb-src http://http.debian.net/debian $VERSION main" >> /etc/apt/sources.list
   
    echo "deb http://security.debian.org/ $VERSION/updates main" >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/ $VERSION/updates main" >> /etc/apt/sources.list
   
    echo "deb http://http.debian.net/debian $VERSION-updates main" >> /etc/apt/sources.list
    echo "deb-src http://http.debian.net/debian $VERSION-updates main" >> /etc/apt/sources.list

    # Update apt-get with the new sources.
    apt-get update

	# Reinstall passwd command and change root password.
	apt-get --reinstall install -y passwd
	passwd

	# Reinstall crucial software.
	apt-get --reinstall install -y bash
	apt-get --reinstall install -y openssl
	apt-get --reinstall install -y coreutils
	apt-get --reinstall install -y vim
	apt-get --reinstall install -y wget
fi

# Lock down the sudoers file.
chattr -i /etc/sudoers
echo "root    ALL=(ALL:ALL) ALL" > /etc/sudoers
chmod 000 /etc/sudoers
chattr +i /etc/sudoers

# Clear cronjobs.
chattr -i /etc/crontab
echo "" > /etc/crontab
chattr +i /etc/crontab
chattr -i /etc/anacrontab
echo "" > /etc/anacrontab
chattr +i /etc/anacrontab

# Check programs that have root privliges
find / -perm -04000 > programsWithRootAccess.txt

# Remove existing ssh keys
rm -rf ~/.ssh/*

# Check for users who should not have root privlages.
groupadd -g 3000 badGroup
while read line
do
    IFS=':' read -a userArray <<< "$line"
    if [ ${userArray[0]} != "root" ]
    then
        # Check UID of users
        userID=$(id -u "${userArray[0]}")
        count=3000
        if [  $userID -eq '0' ]
        then
            usermod -u $count ${userArray[0]}
            $count++
        fi

        # Check GID of users
        groupID=$(id -g "${userArray[0]}")
        if [  $groupID -eq '0' ]
        then
            usermod -g 3000 ${userArray[0]}
        fi
    fi
done < '/etc/passwd'

# Remove users from the root group.
rootGroup=$(awk -F':' '/root/{print $4}' /etc/group)
for i in "${rootGroup[@]}"
do
    if [[ $i =~ ^$ ]]
    then
        continue
    fi
    usermod -a -G badGroup $i
    gpasswd -d $i root
done

# Upgrade all packages.
if [[ $OS == 'ubuntu' || $OS == 'debian' ]]; then
    apt-get update
    apt-get -y upgrade
fi

# Reboot the system
reboot
