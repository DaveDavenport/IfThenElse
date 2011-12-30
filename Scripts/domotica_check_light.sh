#!/bin/bash

STATE=$(k8055 | awk -F';' '{print $4}')


if [ $STATE -gt 230 ];
then
	exit 1
else
	exit 0
fi
