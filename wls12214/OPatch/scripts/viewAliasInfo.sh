#!/bin/sh

# Set classpath
mypwd="`pwd`"

# Determine the location of this script...
SCRIPTNAME=$0
case ${SCRIPTNAME} in
/*)  SCRIPTPATH=`dirname "${SCRIPTNAME}"` ;;
 *)  SCRIPTPATH=`dirname "${mypwd}/${SCRIPTNAME}"` ;;
esac

# Set JAXB_version
JAXB_VERSION="2.3.0"
ORACLE_HOME="${SCRIPTPATH}/../.."
IS_NEXT_GEN=false
if [ -d "${ORACLE_HOME}/oui/modules" ] ; then
   #NextGen OUI home check if 'modules' directory exists
   IS_NEXT_GEN=true
   MODULES_DIR=`cd ${SCRIPTPATH}/../modules ; pwd`
   JAXB_LOCATION=`cd ${ORACLE_HOME}/oui/modules/private ; pwd`
   JAXB_CLASSPATH="${JAXB_LOCATION}/jaxb-core-${JAXB_VERSION}.jar:${JAXB_LOCATION}/jaxb-impl-${JAXB_VERSION}.jar:${JAXB_LOCATION}/jaxb-xjc-${JAXB_VERSION}.jar"
else
   #Not NextGen
   MODULES_DIR=`cd ${SCRIPTPATH}/../modules ; pwd`
   JAXB_LOCATION=`cd ${ORACLE_HOME}/OPatch/modules/internal/features ; pwd`
   JAXB_CLASSPATH="${JAXB_LOCATION}/lib_jaxb_${JAXB_VERSION}.jar"
fi

OPATCH_COMMON_API_CLASSPATH="${MODULES_DIR}/features/oracle.glcm.opatch.common.api.classpath.jar:${JAXB_CLASSPATH}"

# Set java command
JAVA_HOME=
JAVA_HOME=`$ORACLE_HOME/oui/bin/getProperty.sh JAVA_HOME`
JAVA=${JAVA_HOME}/bin/java

# Run the utility to check config patch inventory
$JAVA -cp $OPATCH_COMMON_API_CLASSPATH -DORACLE_HOME=$ORACLE_HOME oracle.glcm.opatch.common.utils.ViewAliasInfo "$@"
