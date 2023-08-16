#!/bin/sh

SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"`
MW_HOME=`cd "${SCRIPTPATH}/../../.." ; pwd`
export MW_HOME
# Delegate to the common delegation script ...
"${SCRIPTPATH}/fmwconfig_common.sh" wlst_internal.sh "$@"

