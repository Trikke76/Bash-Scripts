#!/bin/bash
#

SUM=0
OVERALL=0

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"` ; do
  PID=`echo $DIR | cut -d / -f 3`
  PROGNAME=`ps -p $PID -o comm --no-headers`
  for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`; do
    let SUM=$SUM+$SWAP
  done
  echo "PID=$PID - Swap used: ${SUM}K - ($PROGNAME )"
  let OVERALL=$OVERALL+$SUM
  SUM=0
done

echo "Overall swap used: $OVERALL"
