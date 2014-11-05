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

# Run the version of the script for ubuntu.
if [ $OS == 'ubuntu' ]; then
	# Fix file repositories
	mv /etc/apt/sources.list /etc/apt/sources.list.backup
	touch /etc/apt/sources.list
	echo "deb http://mirrors.rit.edu/ubuntu/ $VERSION main" >> /etc/apt/sources.list
	echo "deb-src http://mirrors.rit.edu/ubuntu/ $VERSION main" >> /etc/apt/sources.list

	# Reinstall passwd command and change root password.
	apt-get --reinstall install -y passwd
	passwd

	# Check for root users by group and UID
	## http://serverfault.com/questions/208347/how-do-i-list-all-users-with-root

	# Reinstall crucial software.
	apt-get install --only-upgrade bash
	apt-get install --only-upgrade openssl
	apt-get --reinstall install -y coreutils
	apt-get --reinstall install -y vim
	apt-get --reinstall install -y wget

	# Update all software
	apt-get update
fi

# Lock down the sudoers file.
echo "root    ALL=(ALL:ALL) ALL" > /etc/sudoers
chmod 000 /etc/sudoers
chattr +i /etc/sudoers

# Clear cronjobs.
echo "" > /etc/crontab
chattr +i /etc/crontab
echo "" > /etc/anacrontab
chattr +i /etc/anacrontab




######### check dns servers