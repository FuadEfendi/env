#!/bin/sh

CMD=setProperty.sh
USAGE="Usage: $CMD [ -jreLoc <Java Home> ] [ -name <variable name> ] [ -value <variable value> ]"

# for identifying unsubbed tokens
AT='@'

# OUI platform name used at install time
PLATFORM_NAME="@PLATFORM_NAME@"

JAVA_HOME_LOCATION="@JAVA_HOME_LOCATION@"

JAVA_OPTIONS="@JAVA_OPTIONS@"
HOTSPOT_JAVA_OPTIONS="@HOTSPOT_JAVA_OPTIONS@"
IBM_JAVA_OPTIONS="@IBM_JAVA_OPTIONS@"
JROCKIT_JAVA_OPTIONS="@JROCKIT_JAVA_OPTIONS@"

d="`dirname $0`"

# Determine the default Java Home location
# 1) if "getProperty JAVA_HOME" provides a value, use it
# 2) else if JAVA_HOME_LOCATION is valid, use it
# 3) else use env variable JAVA_HOME
# Later, this default may be overridden by -jreLoc option

JRELOC=""
if [ -x "$d/getProperty.sh" ] ; then
	JRELOC="`$d/getProperty.sh JAVA_HOME 2>/dev/null`"
fi

if [ -z "$JRELOC" -o ! -d "$JRELOC" ] ; then
	JRELOC="$JAVA_HOME_LOCATION"
fi

if [ -z "$JRELOC" -o ! -d "$JRELOC" ] ; then
	JRELOC="$JAVA_HOME"
fi

# fail if executed as ". setProperty.sh"
b="`basename $0 2>/dev/null`"
if [ "$b" != "$CMD" ] ; then
	echo "$USAGE"
	return
fi

# override the default JRELOC with -jreLoc if specified
getnext=no

# pick the 1st -jreLoc <arg>
for arg in "$@" ; do
	if [ "$getnext" = yes ] ; then
		JRELOC="$arg"
		break
	fi
        lower="`echo $arg|tr '[A-Z]' '[a-z]'`"
	if [ x"$lower" = x-jreloc ] ; then
		getnext=yes
	fi
done

if [ -z "$JRELOC" ] ; then
	echo "ERROR: Cannot determine the Java Home"
	echo "ERROR: Specify the -jreLoc option or export JAVA_HOME"
	exit 1
fi

if [ ! -d "$JRELOC" ] ; then
	echo "ERROR: Java Home directory \"$JRELOC\" does not exist"
	exit 1
fi

case `uname -s` in
Windows*|CYGWIN*)
	AOUT="java.exe"
	;;
*)
	AOUT="java"
	;;
esac

if [ ! -f "$JRELOC/bin/$AOUT" ] ; then
	echo "ERROR: Java Home directory \"$JRELOC\" does not contain bin/$AOUT"
	exit 1
fi

if [ "$JAVA_OPTIONS" = "${AT}JAVA_OPTIONS${AT}" ] ; then
	unset JAVA_OPTIONS
fi

# determine VM_TYPE and JVM options
version=`$JRELOC/bin/$AOUT -version 2>&1`
case "$version" in
*HotSpot*)
	VM_TYPE=HotSpot
	if [ "$HOTSPOT_JAVA_OPTIONS" != "${AT}HOTSPOT_JAVA_OPTIONS${AT}" ] ; then
		JAVA_OPTIONS="$HOTSPOT_JAVA_OPTIONS $JAVA_OPTIONS"
	fi
	;;
*JRockit*)
	VM_TYPE=JRockit
	if [ "$JROCKIT_JAVA_OPTIONS" != "${AT}JROCKIT_JAVA_OPTIONS${AT}" ] ; then
		JAVA_OPTIONS="$JROCKIT_JAVA_OPTIONS $JAVA_OPTIONS"
	fi
	;;
*IBM*)
	VM_TYPE=IBM
	if [ "$IBM_JAVA_OPTIONS" != "${AT}IBM_JAVA_OPTIONS${AT}" ] ; then
		JAVA_OPTIONS="$IBM_JAVA_OPTIONS $JAVA_OPTIONS"
	fi
	;;
*)	VM_TYPE=
	;;
esac

# add -d64 if the install-time platform was Solaris_SPARC64, etc.
# assume -d32 is the default, therefore not needed explicitly
case "$PLATFORM_NAME" in
Solaris_SPARC64|Intel_Solaris|MAC-OS-IN64|HP_IA64)
	JAVA_OPTIONS="-d64 $JAVA_OPTIONS"
	;;
esac

# change to directory containing this script
cd "$d"
if [ -f "../modules/installer-launch.jar" ] ; then
	JAR="../modules/installer-launch.jar"
    OHOME="../.."
else
	echo "ERROR: Cannot locate the OUI runtime.  Exiting"
	exit 1
fi

MAIN_CLASS=com.oracle.cie.gdr.tools.SetProperty

# To accommodate GLCM_HOME env:
# must allow -oracleHome to be overridden on the command line.
# Last -oracleHome option overrides previous settings.
"$JRELOC/bin/$AOUT" $JVM_ARGS $JAVA_OPTIONS -classpath "$JAR" $MAIN_CLASS -oracleHome "$OHOME" "$@"

exit $?
