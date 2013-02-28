#!/bin/bash
RC=0

if [ -f /opt/op5/plugins/utils.sh ] ; then
    . /opt/op5/plugins/utils.sh
fi

# Get list of aggregates
get_aggrs () {
	AGGRS=`/usr/bin/sudo /usr/sbin/dladm show-aggr -p|grep ^aggr|awk '{print $2}'|awk -F'=' '{print $2}'`
	#echo $AGGRS
}

# Takes one argument: the aggregate key id (integer)
get_aggr_devices () {
	AGGRKEY=$1
	DEVS=`/usr/bin/sudo /usr/sbin/dladm show-aggr -p $AGGRKEY|grep ^dev|awk '{print $3}'|awk -F'=' '{print $2}'`
	#echo $DEVS
}

# Get status of a device from dladm, return "up" or "down"
get_dev_linkstatus () {
	DEV=$1
	DEVSTATUS=`/usr/bin/sudo /usr/sbin/dladm show-dev -p|grep $DEV|awk '{print $2}'|awk -F'=' '{print $2}'`
	#echo $DEVSTATUS
}

STATUSLINE=""
get_aggrs
for aggr in $AGGRS; do
	get_aggr_devices $aggr
#	echo $DEVS
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
