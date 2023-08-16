#!/bin/sh

CMD=getVariable.sh

USAGE="Usage: $CMD <VARIABLE_NAME>"

# fail if executed as ". getVariable.sh"
b=`basename "$0" 2>/dev/null`
if [ "$b" != "$CMD" ] ; then
  echo "$USAGE"
  exit 1
fi

SCRIPT_PATH=`dirname "$0"`

#Parse arguments
upper=`echo $1|tr '[a-z]' '[A-Z]'`

if [ -z "$1" -o x"$upper" = "x-HELP" ] ; then
  echo "$USAGE"
  exit 1
else
  VARIABLE_NAME=$1
fi

#Get properties file directory path
#WARNING: in GLCM_HOME env this is GLCM_HOME/nextgen/oui/.globalEnv.properties
PROPERTIES_FILE="${SCRIPT_PATH}/../.globalEnv.properties"

PROPERTY_VALUE=`grep "^${VARIABLE_NAME}=" "${PROPERTIES_FILE}" | cut -d = -f 2 | sed s,'\\\\\\\\',/,g | sed s,'\\\\:',:,g`
echo "${PROPERTY_VALUE}"
