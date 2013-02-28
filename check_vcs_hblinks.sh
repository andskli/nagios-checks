#!/bin/bash

if [ -f /opt/op5/plugins/utils.sh ] ; then
    . /opt/op5/plugins/utils.sh
fi
RC=0
HBDEVS=`grep ^link /etc/llttab|awk '{print $3}'|sed 's/://;s_/dev/__'`
get_link_status () {
    echo `dladm show-dev $1 -p|awk '{print $2}'|awk -F'=' '{print $2}'`
}

STATUSLINE=""
for dev in $HBDEVS; do
    DEVSTATUS=`get_link_status $dev|tr '[a-z]' '[A-Z]'`
    STATUSLINE="${STATUSLINE} ${dev}:${DEVSTATUS}"
    if [ "$DEVSTATUS" != "UP" ]; then
        RC=$STATE_CRITICAL
    fi
done

if [ "$RC" == "$STATE_CRITICAL" ]; then
    echo "CRITICAL: $STATUSLINE - one or more HB links offline"
else
    echo "OK: $STATUSLINE - all HB links are online"
fi
exit $RC
