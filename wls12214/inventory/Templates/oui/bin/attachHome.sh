#!/bin/sh

CMD=attachHome.sh

USAGE="Usage: $CMD [ option ... ]"

# Initial OHOME is the default value.
# In GLCM_HOME env: default must be explicitly overridden on the command line.
OHOME="@ORACLE_HOME@"
OHOMENAME="@ORACLE_HOME_NAME@"

# fail if executed as ". attachHome.sh"
b="`basename $0 2>/dev/null`"
if [ "$b" != "$CMD" ] ; then
	echo "$USAGE"
	return
fi

d="`dirname $0`"

# To accommodate GLCM_HOME env:
# must allow ORACLE_HOME to be overridden on the command line
# so specify the default first.
# Always allow ORACLE_HOME_NAME to be overridden
# if attaching to another inventory where name is already present
# or if it has changed since initial install by previous attachHome.
# Command line overrides response file so pass override
# ORACLE_HOME= on the command line.
"$d/launch.sh" -attachHome ORACLE_HOME="$OHOME" ORACLE_HOME_NAME="$OHOMENAME" "$@"
