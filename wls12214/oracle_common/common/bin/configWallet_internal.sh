#!/bin/sh
#
# Copyright (c) 2014, 2016 Oracle and/or its affiliates. All rights reserved.

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./configWallet.sh)
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

umask 027

# set up common environment
. "${SCRIPTPATH}/commEnv.sh"

CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${DERBY_CLASSPATH}${CLASSPATHSEP}${POINTBASE_CLASSPATH}"
export CLASSPATH

if [ -d "${JAVA_HOME}" ]; then
  eval '"${JAVA_HOME}/bin/java"' ${CONFIG_JVM_ARGS} com.oracle.cie.domain.script.WalletTool '"$@"'
else
 exit 1
fi
