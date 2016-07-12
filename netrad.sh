#!/bin/bash

# netrad.sh
# net radio will post some handy info to a Slack room about what your box is
# doing, maybe.


# Create an Incoming Webhook at
# https://zzmag.slack.com/apps/A0F7XDUAZ-incoming-webhooks
# Then paste the slug below
SLUG=

function getOS() {
  OS=`uname`
}

function getDistro() {
  if [ ${OS} = "Darwin" ]; then
    DISTRO="macOS `sw_vers -productVersion`"
  else
    DISTRO=`lsb_release -a | grep 'Description' | sed -e 's/Description:\s//'`
  fi
}

function getServerTime() {
  SERVER_TIME=`date`
}

function getUptime() {
  UPTIME=`uptime | awk -F, '{sub(".*up ",x,$1);print $1}'`
}

function getDiskSpace() {
  DISK_SPACE=`/bin/df -h | grep ^/dev/ | awk '{print "  ", $1":", $3, "of", $2, "used"}'`
}

function getInternalIP() {
  INTERNAL_IP=`/sbin/ifconfig wlan0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
}

function getExternalIP() {
  EXTERNAL_IP=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
}

function createAvatar() {
  if [ ${OS} = "Darwin" ]; then
    AVATAR_SLUG=`echo ${HOSTNAME} | md5`
  else
    AVATAR_SLUG=`echo ${HOSTNAME} | md5sum | cut -d' ' -f1`
  fi
  AVATAR_URL="http://www.gravatar.com/avatar/${AVATAR_SLUG}?d=retro&f=y"
}

function createRadioMessage() {
# not indented due to Slack formatting
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
