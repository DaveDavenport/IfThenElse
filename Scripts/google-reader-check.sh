#!/bin/bash

VALUE=$(python ./Scripts/google-reader.py)
OLD_VALUE=$(cat ~/.google-reader-unread)


echo $VALUE > ~/.google-reader-unread
if [ x"$VALUE" == x"$OLD_VALUE" ] 
then
	exit 0
fi

if [ "$VALUE" > 0 ] 
then
	exit 1;
else
	exit -1
fi
