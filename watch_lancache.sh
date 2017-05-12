#!/bin/sh

STEAMCACHE_LOGS=data/logs
STEAMCACHE_DEPOTINFO=data/info

echo "Watching logs..."

tail -F ${STEAMCACHE_LOGS}/access.log | while read LINE; do
  IP="$(echo ${LINE} | grep -o '192.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')"
  NAME="$(nslookup $IP | sed -n 's/.*arpa.*name = \(.*\)/\1/p')"

  echo "hostname: ${NAME}"
  echo "ip: ${IP}"

  if [[ $LINE == *"windowsupdate"* ]]; then
    echo "Windows update:"
  fi

  if [ "$LINE" = *"blizzard"* ] || [ "$LINE" == *"blzd"* ] ; then
    echo "Blizzard download:"
  fi

  if [[ $LINE == *"steam"* ]]; then
    GAMEID="$(echo ${LINE} | grep '\/depot' | sed 's/.*\/depot\/\([0-9]*\)\/.*/\1/')"
    if ! [ -f ${STEAMCACHE_DEPOTINFO}/${GAMEID} ]; then
      wget -O ${STEAMCACHE_DEPOTINFO}/${GAMEID} https://steamdb.info/depot/${GAMEID}
    fi
    G="$(cat ${STEAMCACHE_DEPOTINFO}/${GAMEID} | grep -o '</span>.*</h1>' | sed -e 's/<[^>]*>//g' | sed -e 's/ Content$//')"
    echo "Steam download: ${G}"
  fi
  echo "${LINE}" | GREP_COLOR='01;31' egrep -i --color=always '^.*MISS.*$|$'| GREP_COLOR='01;32' egrep -i --color=always '^.*HIT.*$|$'
  echo
done
