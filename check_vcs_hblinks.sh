#!/bin/bash
RC=0

SUDOBIN=$(which sudo)
DLADMBIN=$(which dladm)
GREPBIN=$(which grep)
AWKBIN=$(which awk)
SEDBIN=$(which sed)

if [ -f /opt/op5/plugins/utils.sh ] ; then
    . /opt/op5/plugins/utils.sh
fi

HBDEVS=`$GREPBIN ^link /etc/llttab|$AWKBIN '{print $3}'|$SEDBIN 's/://;s_/dev/__'`

get_link_status () {
    echo `$SUDOBIN $DLADMBIN show-dev $1 -p|$AWKBIN '{print $2}'|$AWKBIN -F'=' '{print $2}'`
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
