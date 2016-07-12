#!/bin/bash

# netrad.sh
#
# About
# --
# Posts some handy info about your box to a Slack channel.
#
# Install
# --
# 1. Create an Incoming Webhook at
# https://my.slack.com/services/new/incoming-webhook/
#
# 2. Paste the Webhook URL slug below
# (everything after "https://hooks.slack.com/services/")
SLUG=
#
# 3. Add to your crontab
# The following will run netrad.sh every 5 minutes, which would probably be
# annoying
#
# */5 * * * * /bin/bash /path/to/netrad.sh


# Get the OS flavour (eg. Linux or Darwin)
function getOS() {
  OS=`uname`
}

# Get the operating system version (eg. Ubuntu 15.04 or 10.11.5)
function getDistro() {
  if [ ${OS} = "Darwin" ]; then
    DISTRO="macOS `sw_vers -productVersion`"
  else
    DISTRO=`lsb_release -a | grep 'Description' | sed -e 's/Description:\s//'`
  fi
}

# Get the local time
function getServerTime() {
  SERVER_TIME=`date`
}

# Get how long the system has been running
function getUptime() {
  UPTIME=`uptime | awk -F, '{sub(".*up ",x,$1);print $1}'`
}

# Get how much space is free on mounted drives
# (thanks @geraintrjones)
function getDiskSpace() {
  DISK_SPACE=`df -h | grep ^/dev/ | awk '{print "  ", $1":", $3, "of", $2, "used"}'`
}

# TODO
# Get the internal IP address
function getInternalIP() {
  INTERNAL_IP=`ifconfig wlan0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
}

# Get the external IP address
function getExternalIP() {
  EXTERNAL_IP=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
}

# Create a unique identicon based on the box ${HOSTNAME}
function createAvatar() {
  if [ ${OS} = "Darwin" ]; then
    AVATAR_SLUG=`echo ${HOSTNAME} | md5`
  else
    AVATAR_SLUG=`echo ${HOSTNAME} | md5sum | cut -d' ' -f1`
  fi
  AVATAR_URL="http://www.gravatar.com/avatar/${AVATAR_SLUG}?d=retro&f=y"
}

# Create the message that is posted to Slack
function createRadioMessage() {
# Not indented due to Slack formatting
RADIO_MESSAGE="
\`\`\`
${HOSTNAME} (Up ${UPTIME})
---
OS: ${DISTRO}
Time: ${SERVER_TIME}
External IP: ${EXTERNAL_IP}
Disk space:
${DISK_SPACE}
\`\`\`"
}

# Post ${RADIO_MESSAGE} to Slack
function postToSlack() {
  curl \
  --request POST \
  --header 'Content-type: application/json' \
  https://hooks.slack.com/services/${SLUG} \
  --data \
  "
  {
    \"username\": \"${HOSTNAME}\",
    \"icon_url\": \"${AVATAR_URL}\",
    \"text\":\"${RADIO_MESSAGE}\"
  }
  "
}

getOS
getDistro
getServerTime
getUptime
getDiskSpace
# getInternalIP
getExternalIP
createAvatar
createRadioMessage
postToSlack
