#!/usr/bin/bash
#
# Copyright (c) 2002 Sprint
# All rights reserved.
#
#ident  "@(#)GeoMonitor  1.0  2002/06/04 LGA"

# loading the profile
. /etc/profile

DIRECTION=$1
PREFIX=/work/WADappl/Projects/GeoNet/
LOGDIR=${PREFIX}scheduled/logs/
LOG=${LOGDIR}NukeHistory${DIRECTION}.log
ERRLOG=${LOGDIR}NukeHistory${DIRECTION}.err
SCHED_DIR=${PREFIX}scheduled

cd $SCHED_DIR

/usr/bin/perl $SCHED_DIR/nuke_history.pl $DIRECTION >> $LOG 2> $ERRLOG

exit 0
