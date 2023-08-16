#!/bin/sh

echo "WARNING: This is a deprecated script. Please invoke the wlst.sh script under oracle_common/common/bin."

mypwd="`pwd`"

case `uname -s` in
Windows_NT*)
  CLASSPATHSEP=\;
;;
CYGWIN*)
  CLASSPATHSEP=\;
;;
*)
  CLASSPATHSEP=:
;;
esac

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./wlst.sh)
SCRIPTNAME=$0
case ${SCRIPTNAME} in
 /*)  SCRIPTPATH=`dirname "${SCRIPTNAME}"` ;;
  *)  SCRIPTPATH=`dirname "${mypwd}/${SCRIPTNAME}"` ;;
esac

# Set CURRENT_HOME...
CURRENT_HOME=`cd "${SCRIPTPATH}/../.." ; pwd`
export CURRENT_HOME

# Set the MW_HOME relative to the CURRENT_HOME...
MW_HOME=`cd "${CURRENT_HOME}/.." ; pwd`
export MW_HOME

# Delegate to the COMMON_COMPONENTS_HOME script...
"${MW_HOME}/oracle_common/common/bin/wlst.sh" "$@"
exit $? 
