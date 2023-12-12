#!/bin/sh

SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"`

MAIN_CLASS=com.oracle.cie.domain.info.VariableModifier

# Delegate to the common delegation script ...
"${SCRIPTPATH}/fmwconfig_common.sh" config_internal.sh $MAIN_CLASS "$@"
