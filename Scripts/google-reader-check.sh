#!/bin/bash

VALUE=$(python ./Scripts/google-reader.py)
OLD_VALUE=$(cat ~/.google-reader-unread)


echo $VALUE > ~/.google-reader-unread
if [ x"$VALUE" == x"$OLD_VALUE" ] 
then
	exit 0
fi
echo "value: $VALUE"
if [ $VALUE -gt 0 ] 
then
	exit 1;
else
	exit 8;
fi
