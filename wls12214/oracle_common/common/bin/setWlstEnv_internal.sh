#!/bin/sh

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


CURRENT_HOME=${MW_HOME}/oracle_common
export CURRENT_HOME

# Set the home directories...
. "${MW_HOME}/oracle_common/common/bin/setHomeDirs.sh"

# Set the DELEGATE_ORACLE_HOME to CURRENT_HOME if it's not set...
ORACLE_HOME="${DELEGATE_ORACLE_HOME:=${CURRENT_HOME}}"
export DELEGATE_ORACLE_HOME ORACLE_HOME

# Some scripts in WLST_HOME reference ORACLE_HOME
WLST_PROPERTIES="${WLST_PROPERTIES} -DORACLE_HOME='${ORACLE_HOME}'"
export WLST_PROPERTIES


umask 027

# set up common environment
if [ ! -z "${WLS_NOT_BRIEF_ENV}" ]; then
  if [ "${WLS_NOT_BRIEF_ENV}" = "true" -o  "${WLS_NOT_BRIEF_ENV}" = "TRUE"  ]; then
    WLS_NOT_BRIEF_ENV=
    export WLS_NOT_BRIEF_ENV
  fi
else
    WLS_NOT_BRIEF_ENV=false
    export WLS_NOT_BRIEF_ENV
fi

. "${MW_HOME}/oracle_common/common/bin/commBaseEnv.sh"

if [ -f "${SCRIPTPATH}/cam_wlst.sh" ] ; then
  . "${SCRIPTPATH}/cam_wlst.sh"
fi

CLASSPATH="${WLST_EXT_CLASSPATH}${CLASSPATHSEP}${FMWCONFIG_CLASSPATH}"

export CLASSPATH


if [ "${WLS_NOT_BRIEF_ENV}" = "" ] ; then
  echo
  echo CLASSPATH=${CLASSPATH}
fi

JVM_ARGS="${WLST_PROPERTIES} ${JVM_D64} ${UTILS_MEM_ARGS} ${CONFIG_JVM_ARGS}"
export WLST_PROPERTIES JVM_ARGS
