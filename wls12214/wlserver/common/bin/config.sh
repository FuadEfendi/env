#!/bin/sh
echo "WARNING: This is a deprecated script. Please invoke the config.sh script under oracle_common/common/bin."

mypwd="`pwd`"

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./config.sh)
SCRIPTNAME=$0
case ${SCRIPTNAME} in
 /*)  SCRIPTPATH=`dirname "${SCRIPTNAME}"` ;;
  *)  SCRIPTPATH=`dirname "${mypwd}/${SCRIPTNAME}"` ;;
esac

# Set the MW_HOME relative to this script...
MW_HOME=`cd "${SCRIPTPATH}/../../.." ; pwd`
export MW_HOME

# Delegate to the main script...
"${MW_HOME}/oracle_common/common/bin/config.sh" "$@"
