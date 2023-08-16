#!/bin/sh

WL_HOME="${MW_HOME}/wlserver"
export WL_HOME

# Set common components home...
COMMON_COMPONENTS_HOME="${MW_HOME}/oracle_common"
if [ -d "${COMMON_COMPONENTS_HOME}" ] ; then
  COMMON_COMPONENTS_HOME=`cd "${MW_HOME}/oracle_common" ; pwd`
fi
export COMMON_COMPONENTS_HOME

if [ -z "${JAVA_HOME}" -o -z "${JAVA_VENDOR}" ]; then
 if [ -d "${JAVA_HOME}" ]; then
   ORIGINAL_JAVA_HOME=${JAVA_HOME}
 fi   
 JAVA_HOME=`${MW_HOME}/oui/bin/getProperty.sh JAVA_HOME`
 if [ -d "${JAVA_HOME}" ]; then
   JAVA_VENDOR=Oracle
   export JAVA_VENDOR
 else
   if [ -d "${ORIGINAL_JAVA_HOME}" ]; then
    JAVA_HOME=${ORIGINAL_JAVA_HOME}
   fi
 fi
 if [ ! -d "${JAVA_HOME}" ]; then
   echo "The jdk ${JAVA_HOME} is not accessible."
   echo "Please set appropriate JAVA_HOME and run again."  
   exit 1
 fi
fi

export JAVA_HOME 
