#!/bin/sh

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./wlst.sh)
SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"` 

# Set CURRENT_HOME...
CURRENT_HOME=`cd "${SCRIPTPATH}/../.." ; pwd`
export CURRENT_HOME

# Set the MW_HOME relative to the CURRENT_HOME...
MW_HOME=`cd "${CURRENT_HOME}/.." ; pwd`
export MW_HOME

. ${MW_HOME}/oracle_common/common/bin/setWlstEnv_internal.sh 
if [ -d "${JAVA_HOME}" ]; then
 eval '"${JAVA_HOME}/bin/java"' ${JVM_ARGS} weblogic.WLST '"$@"'
else
 exit 1 
fi

