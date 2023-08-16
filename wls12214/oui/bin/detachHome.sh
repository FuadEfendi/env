#!/bin/sh

CMD=detachHome.sh

USAGE="Usage: $CMD [ option ... ]"

OHOME="c:\Users\xiaol\Downloads\wls\wls12214"

# fail if executed as ". detachHome.sh"
b="`basename $0 2>/dev/null`"
if [ "$b" != "$CMD" ] ; then
	echo "$USAGE"
	return
fi

d="`dirname $0`"

# To accommodate GLCM_HOME env:
# must allow ORACLE_HOME to be overridden on the command line.
# Command line overrides response file so pass override
# ORACLE_HOME= on the command line.
"$d/launch.sh" -detachHome ORACLE_HOME="$OHOME" "$@"
