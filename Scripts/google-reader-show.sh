#!/bin/bash

OLD_VALUE=$(cat ~/.google-reader-unread)

notify-send "Google Reader: $OLD_VALUE Unread messages"
