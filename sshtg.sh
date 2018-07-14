#!/bin/bash
USERNAME=$1
HOSTS=$2
MOUNT=$3
SCRIPT="df | grep $MOUNT | grep -o '[0-9]\{1,3\}%'"
ALARM=40
red='\033[1;31m'
nc='\033[0m'
green='\033[0;32m'

# checking arguments
if [[ ! $3 ]]; then
  echo "missing arguments,use - $0 user host mount"
  exit
fi

# function to connect
sshConnect(){
  for HOSTNAME in ${HOSTS} ; do
      RETURN=`ssh -q -l ${USERNAME} ${HOSTNAME} ${SCRIPT} | grep -o '[0-9]\{1,3\}'`
  done

  MSG="${HOSTS}:${MOUNT} have ${RETURN}% space used"
  echo $MSG

  if [[ $RETURN -lt $ALARM ]]; then
    FREE=`echo "100 - $RETURN" | bc -l`
    echo "${HOSTS}:${MOUNT} have $FREE% free disk space"
  else
    FREE=`echo "100 - $RETURN" | bc -l`
    echo "${HOSTS}:${MOUNT} have $FREE % free disk space"
  fi

}

# Telegram vars
sshTg(){
URL=https://api.telegram.org/ #telegram uri
botToken=bot535199740:AAGhxdpQz5XDW8oSD8JYdpE0aRdXdUZwRrU #xtgxbot made with botfather
chatId=-220750192
curl -s -X POST "${URL}${botToken}/sendMessage" -d "chat_id=${chatId}&text=${MSG}" | json_pp >> $HOSTS.json
}

# exec
sshConnect
sshTg