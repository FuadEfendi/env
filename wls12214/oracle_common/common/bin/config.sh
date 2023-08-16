#!/bin/sh

SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"`

MAIN_CLASS=com.oracle.cie.wizard.WizardController

# Delegate to the common delegation script ...
"${SCRIPTPATH}/fmwconfig_common.sh" config_internal.sh $MAIN_CLASS "$@"

