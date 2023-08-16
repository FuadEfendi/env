#!/bin/sh

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./unpack.sh)
SCRIPTNAME=$0
SCRIPTPATH=`dirname "${SCRIPTNAME}"` 

# Set the ORACLE_HOME relative to this script...
ORACLE_HOME=`cd "${SCRIPTPATH}/../.." ; pwd`
export ORACLE_HOME

# Set the MW_HOME relative to the ORACLE_HOME...
MW_HOME=`cd "${ORACLE_HOME}/.." ; pwd`
export MW_HOME

# Set the home directories...
. "${SCRIPTPATH}/setHomeDirs.sh"

OS=`uname -s`

umask 027

# set up common environment
. "${SCRIPTPATH}/commEnv.sh"

CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${DERBY_CLASSPATH}${CLASSPATHSEP}${POINTBASE_CLASSPATH}"
export CLASSPATH

if [ -f "${SCRIPTPATH}/cam_unpack.sh" ] ; then
  . "${SCRIPTPATH}/cam_unpack.sh"
fi

JVM_ARGS="${UTILS_MEM_ARGS} ${SECURITY_JVM_ARGS} ${CONFIG_JVM_ARGS}"

if [ -d "${JAVA_HOME}" ]; then
  eval '"${JAVA_HOME}/bin/java"' ${JVM_ARGS} com.oracle.cie.domain.script.Unpacker '"$@"'
else
 exit 1 
fi 
