#!/bin/sh

STEAMCACHE_LOGS=data/logs
STEAMCACHE_DEPOTINFO=data/info

echo "Watching logs..."

tail -F ${STEAMCACHE_LOGS}/access.log | while read LINE; do
  echo
  GAMEID="$(echo ${LINE} | grep '\/depot' | sed 's/.*\/depot\/\([0-9]*\)\/.*/\1/')"
  echo "GAME_ID = ${GAMEID}"
  if ! [ -f ${STEAMCACHE_DEPOTINFO}/${GAMEID} ]; then
    wget -O ${STEAMCACHE_DEPOTINFO}/${GAMEID} https://steamdb.info/depot/${GAMEID}
  fi
  G="$(cat ${STEAMCACHE_DEPOTINFO}/${GAMEID} | grep -o '</span>.*</h1>' | sed -e 's/<[^>]*>//g' | sed -e 's/ Content$//')"
  echo
  echo "GAME_ID = ${GAMEID}"
  echo "GAME_NAME =${G}"
  echo "${LINE}" | GREP_COLOR='01;31' egrep -i --color=always '^.*MISS.*$|$'| GREP_COLOR='01;32' egrep -i --color=always '^.*HIT.*$|$'
done
