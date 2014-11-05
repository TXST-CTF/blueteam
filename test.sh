#!/bin/bash
# Name: secure.sh
# Author: Mark Spicer
# Purpose: To secure a machine during a security competition.

# Get an array of all users on the system.
USERS=($(cut -d: -f1 /etc/passwd))

for i in "${USERS[@]}"; 
do
	if [ $i == 'root' ]; then
		continue
	elif [ $i == 'vagrant' ]; then
		continue
	else
		# Disable user account and set bin to /bin/false.
		usermod -L -e 1 $i
		usermod -s /bin/false $i

		# Get user ID.		
		USERID=($( id -u $i ))

		if [ $USERID == 0 ]; then
			# Make sure the UID is not zero.
			usermod -u $RANDOM $i
		elif [ $USERID >= 1000 ]; then
			# If the user is a login user, kill all processes belonging to the user.
			

		fi
	fi
done