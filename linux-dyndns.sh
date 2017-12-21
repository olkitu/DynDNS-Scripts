#!/bin/bash
USERNAME="username"
PASSWORD="password"
HOSTNAME="dyndnsurl"
UPDATEURL="updateurl"
IP=`curl -4 -s https://$UPDATEURL/nic/checkip | grep -o '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}'`

ABUSE_LOCK_FILE="/tmp/dyndns.abuse"
LAST_IP_FILE="/tmp/lastip"
LAST_IP=`cat $LAST_IP_FILE`

#lockfile check, lockfile is only used if a abuse result appears
if [ -e "$ABUSE_LOCK_FILE" ]; then
    echo "Dyndns abuse lockfile exisits: $ABUSE_LOCK_FILE"
    exit 1
fi
#end of lockfile check

if [ "$IP" != "$LAST_IP" ]; then
    echo "Current IP: $IP"
    RESULT=`curl  "https://$USERNAME:$PASSWORD@$UPDATEURL/nic/update?hostname=$HOSTNAME&myip=$IP" | grep -o -E  "good|nochg|abuse|badauth|notfqdn|nohost|abuse|dnserr"`
    echo "DynDNS says: $RESULT!"
	if [ "$RESULT" == "good" ]; then
		echo $IP > "/tmp/lastip"
	fi
else
    echo "IP is still the same: $LAST_IP"
fi
