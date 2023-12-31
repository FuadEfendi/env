#!/bin/sh

if [ -z  "${QS_TEMPLATES}" ]; then  
  if [ "$1" != "-help" ] ; then
    echo "QS_TEMPLATES env variable not set."
    exit 1
  fi
fi  

CONFIG_JVM_ARGS="-DuserTemplates='${QS_TEMPLATES}' ${CONFIG_JVM_ARGS}" 
export CONFIG_JVM_ARGS

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./qs_config.sh)
SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"`

# Set the MW_HOME relative to this script...
MW_HOME=`cd "${SCRIPTPATH}/../../.." ; pwd`
export MW_HOME

if [ "$1" = "-help" ] ; then
  "${MW_HOME}/oracle_common/common/bin/config.sh" "$@"
else
  "${MW_HOME}/oracle_common/common/bin/config.sh" -target=config-oneclick "$@"
fi
returnCode=$?

exit $returnCode

