#!/bin/bash

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
