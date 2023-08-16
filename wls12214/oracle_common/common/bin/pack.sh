#!/bin/sh

SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"`

# Delegate to the common delegation script ...
"${SCRIPTPATH}/fmwconfig_common.sh" pack_internal.sh "$@"

