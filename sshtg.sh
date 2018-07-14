#!/bin/bash
USERNAME=$1
HOSTS=$2
MOUNT=$3
ALARM=$4
SCRIPT="df | grep $MOUNT | grep -o '[0-9]\{1,3\}%'"

# checking arguments
if [[ ! $4 ]]; then
  echo "missing arguments,use - $0 user host mount percent"
  exit
fi

# function to connect
sshConnect(){
  for HOSTNAME in ${HOSTS} ; do
      RETURN=`ssh -q -l ${USERNAME} ${HOSTNAME} ${SCRIPT} | grep -o '[0-9]\{1,3\}'`
  done

  MSG="${HOSTS}:${MOUNT} have ${RETURN}% space used"
  echo $MSG
}

# function to alarm disk space
sshAlarm(){
  if [[ $RETURN -lt $ALARM ]]; then
    FREE=`echo "100 - $RETURN" | bc -l`
    echo "${HOSTS}:${MOUNT} have $FREE% free disk space"
  else
    FREE=`echo "100 - $RETURN" | bc -l`
    echo "${HOSTS}:${MOUNT} have $FREE % free disk space - ALERT"
  fi
}

# Telegram function
sshTg(){
  URL=https://api.telegram.org/ #telegram uri
  botToken=bot535199740:AAGhxdpQz5XDW8oSD8JYdpE0aRdXdUZwRrU #xtgxbot made with botfather
  chatId=-220750192
  curl -s -X POST "${URL}${botToken}/sendMessage" -d "chat_id=${chatId}&text=${MSG}" | json_pp >> $HOSTS.json
}

# exec
sshConnect
sshAlarm
sshTg