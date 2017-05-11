#!/bin/sh

STEAMCACHE_LOGS=data/logs
STEAMCACHE_DEPOTINFO=data/info

echo "Watching logs..."

tail -F ${STEAMCACHE_LOGS}/access.log | while read LINE; do
  echo
  echo "${LINE}" | GREP_COLOR='01;31' egrep -i --color=always '^.*MISS.*$|$'| GREP_COLOR='01;32' egrep -i --color=always '^.*HIT.*$|$'
done
