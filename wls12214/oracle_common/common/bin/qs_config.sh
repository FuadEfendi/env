#!/bin/sh

SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"`

# Delegate to the common delegation script ...
"${SCRIPTPATH}/fmwconfig_common.sh" qs_config_internal.sh "$@"

