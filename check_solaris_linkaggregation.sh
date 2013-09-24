#!/bin/bash
#
# check_solaris_linkaggregation.sh
#
# Check Solaris dladm link aggregationx86
#
# Author: Andreas Lindh
#

RC=0

DLADMBIN=$(which dladm)
SUDOBIN=$(which sudo)
AWKBIN=$(which awk)

if [ -f /opt/op5/plugins/utils.sh ] ; then
    . /opt/op5/plugins/utils.sh
fi

# Get list of aggregates
get_aggrs () {
	AGGRS=`$SUDOBIN $DLADMBIN show-aggr -p|grep ^aggr|$AWKBIN '{print $2}'|$AWKBIN -F'=' '{print $2}'`
}

# Takes one argument: the aggregate key id (integer)
get_aggr_devices () {
	AGGRKEY=$1
	DEVS=`$SUDOBIN $DLADMBIN show-aggr -p $AGGRKEY|grep ^dev|$AWKBIN '{print $3}'|$AWKBIN -F'=' '{print $2}'`
}

# Get status of a device from dladm, return "up" or "down"
get_dev_linkstatus () {
	DEV=$1
	DEVSTATUS=`$SUDOBIN $DLADMBIN show-dev -p|grep $DEV|$AWKBIN '{print $2}'|$AWKBIN -F'=' '{print $2}'`
}

STATUSLINE=""
get_aggrs
for aggr in $AGGRS; do
	get_aggr_devices $aggr
	for dev in $DEVS; do
		get_dev_linkstatus $dev
        DEVSTATUS=`echo $DEVSTATUS|tr '[a-z]' '[A-Z]'`
		STATUSLINE="${STATUSLINE} ${dev}:${DEVSTATUS}"
        if [ "$DEVSTATUS" != "UP" ]; then
            RC=$STATE_WARNING
            BROKENDEVS="${BROKENDEVS} ${dev}"
        fi
	done
done

if [ "$RC" == "$STATE_WARNING" ]; then
    echo "WARNING: $STATUSLINE - check devices: $BROKENDEVS"
else
    echo "OK: $STATUSLINE - all devices are online"
fi
exit $RC
