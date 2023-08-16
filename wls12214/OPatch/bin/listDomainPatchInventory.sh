#!/bin/sh

#help detect
help=0;
if [ "$1" = "-h" ]; then
   help=1
elif [ "$1" = "-help" ]; then
   help=1
fi
if [ $help = 1 ]; then
   echo "Syntax:  listDomainPatchInventory <domain_directory>"
   echo "Usage: This command provides the information about configured" 
   echo "       actions and patches in the domain inventory."
   exit ;
fi

# Get domain home directory
if [ "$1" == "" ] ; then 
   echo "Please enter the domain home directory (e.g. $0 \$DOMAIN_HOME)";
   exit ;
else 
   DOMAIN_HOME="$1" ;
#   echo $DOMAIN_HOME ;
fi

# Set classpath
mypwd="`pwd`"

	# Determine the location of this script...
SCRIPTNAME=$0
case ${SCRIPTNAME} in
/*)  SCRIPTPATH=`dirname "${SCRIPTNAME}"` ;;
 *)  SCRIPTPATH=`dirname "${mypwd}/${SCRIPTNAME}"` ;;
esac

MODULES_DIR=`cd ${SCRIPTPATH}/../modules ; pwd`
ORACLE_COMMON_MODULES_DIR=`cd ${SCRIPTPATH}/../../oracle_common/modules ; pwd`
OPATCH_COMMON_API_CLASSPATH="${MODULES_DIR}/features/oracle.glcm.opatch.common.api.classpath.jar:${ORACLE_COMMON_MODULES_DIR}/internal/features/lib_jaxb_2.3.0.jar"

# Set java command
ORACLE_HOME="${SCRIPTPATH}/../../"
JAVA_HOME=
JAVA_HOME=`$ORACLE_HOME/oui/bin/getProperty.sh JAVA_HOME`
JAVA=${JAVA_HOME}/bin/java

# Run the utility to check config patch inventory
$JAVA -cp $OPATCH_COMMON_API_CLASSPATH oracle.glcm.opatch.common.utils.CheckConfigPatchInventory $DOMAIN_HOME
