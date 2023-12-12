#!/bin/sh
#
# copyBinary.sh
#
# Copyright (c) 2010, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      copyBinary.sh - Script to copy Oracle Middleware home binary
#
#    DESCRIPTION
#      This script is used to create the archive of an Oracle Middleware Home.
#      This script invokes the OUI implementation and has one mandatory parameter
#      to call the implementation.
#
#      -javaHome   - java home location.
#
#    NOTES
#      Based on the copyBinary.sh created by ASINST team
#


# Declare variables for use
args=$*
argsarray=""
isorahomeprovided=
isarchivelocprovided=

case `uname -s` in
Windows*|CYGWIN*)
	AOUT="java.exe"
	;;
*)
	AOUT="java"
	;;
esac

# Help message for copyBinary
help() {

	echo "usage: "
	echo "       Options in brackets [] are optional"
	echo ""
	echo "       copyBinary.sh"
	echo ""
	echo "       -archiveLoc archive_location"
	echo "       -sourceOracleHomeLoc source_Oracle_Home"
	echo ""
	echo "       [-javaHome java_home]"
	echo "       [-silent true|false]"
	echo "       [-ignoreDiskWarning false|true]"
	echo "       [-ignoreDefaultExcludes false|true]"
	echo "       [-excludeFilesPattern <regex1>,<regex2> ...]"
	echo "       [-maxArchiveSize <MB>]"
	echo "       [-includeDirs <dir1>,<dir2> ...]"
	echo ""
	echo "Try \"copyBinary.sh -help\" for more information."
	exit 1
	
}

# To validate javaHome value
 validate_java_home() {
 
	java_home="$1"
	
	if [ ! -d "${java_home}" ];then
	
		echo "Java home location is invalid because \"${java_home}\" is not a directory."
		exit 1
		
	fi

	if [ ! -f "$java_home/bin/${AOUT}" ];then
	
		echo "Java home location is invalid because  \"${java_home}/bin/${AOUT}\" does not exist."
		exit 1
		
	fi
	
 }

# Validate Oracle Home is a directory else cannot get absolute path
validate_oracle_home() {

	oh="$1"

	if [ ! -d "${oh}" ];then

		echo "Oracle Home location is invalid because \"${oh}\" is not a directory."
  		exit 1

	fi

}

# Iterate through the command line parameters to check the mandatory params required to execute the cloningclient

# prevopt is non-empty only if previous opt is a valid
# copyBinary-specific option
prevopt=""
for tempvar in "$@" ; do
	
	#convert the argument to a lower case to make the comparison case insensitive 
	lower=`echo ${tempvar}|tr '[A-Z]' '[a-z]'`

	case "x$lower" in
	x-archiveloc|x-sourceoraclehomeloc|x-javahome|x-silent|x-ignorediskwarning|x-ignoredefaultexcludes|x-excludefilespattern|x-maxarchivesize|x-includedirs|x-invptrloc)
		# set prevopt only if this is a valid copyBinary-specific option
		if [ -n "${prevopt}" ] ; then
			# e.g. copyBinary.sh -silent -archiveLoc /tmp/generic.jar ...
			echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by a value, not another dashed option)."
			help
		fi
		prevopt="${lower}"
		;;
	x-d64)
		# ignore -d64 because launch.sh determines the correct value
		if [ -n "${prevopt}" ] ; then
			# e.g. copyBinary -silent -d64 -archiveLoc ...
			echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by a value, not another dashed option)."
			help
		fi
		prevopt=""
		;;
	x-help)
		# print usage message and exit
		help
		;;
	*)
		case "x${prevopt}" in
		x)
			# prevopt is empty, therefore not a recognized
			# copyBinary-specific option
			# so pass on this opt without change
			# e.g. -debug, which will be accepted by Launcher
			# e.g. -nowait, also accepted by Launcher, valid with MKS
			# e.g. -bogus, which will be rejected by Launcher
			argsarray="${argsarray} ${tempvar}"
			;;

		x-archiveloc)
			# Launcher must validate -archiveLoc
			argsarray="${argsarray} -archiveLoc ${tempvar}"
			isarchivelocprovided=true
			;;

		x-javahome)
			# do not pass invalid Java Home to launch.sh
			validate_java_home ${tempvar}
			javaHome="`cd ${tempvar}; pwd`"
			argsarray="${argsarray} -jreLoc ${javaHome}"
			;;

		x-sourceoraclehomeloc)
			# verify Oracle Home exists else cannot cd to get absolute path
			validate_oracle_home ${tempvar}
			oh="`cd ${tempvar}; pwd`"
			argsarray="${argsarray} ORACLE_HOME=${oh}"
			isorahomeprovided=true
			;;

		x-excludefilespattern|x-maxarchivesize|x-includedirs)
			argsarray="${argsarray} ${prevopt} ${tempvar}"
			;;
			
		x-invptrloc)
			# Ignore -invPtrLoc, this is an special handling to provide compatibilty with FMW copyBinary.
			echo "Ignoring the option -invPtrLoc for this operation."
			;;

		x-silent)
			# disallow -silent xyz but then ignore it
			# because -silent false is not supported
			if [ "$lower" != "true" -a "$lower" != "false" ] ; then
				echo "Invalid option ${prevopt} ${tempvar} (value must be true or false)"
				help
			fi
			;;

		x-ignorediskwarning|x-ignoredefaultexcludes)
			if [ "$lower" = "true" ] ; then
				argsarray="${argsarray} ${prevopt}"
			elif [ "$lower" != "false" ] ; then
				echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by true or false)"
				help
			fi
			;;

		*)
			# internal error? all valid copyBinary-specific options
			# should be in the above case statement
			echo "Invalid option sequence ${prevopt} ${tempvar}"
			help
			;;
		esac

		prevopt=""
		;;
	esac
done

# Check if last argument was an option
if [ -n "${prevopt}" ];then
	echo "Invalid option ${prevopt} (requires a value)"
	help	
fi

if [ "${isorahomeprovided}" != "true" ];then
	echo "Option -sourceOracleHomeLoc must be provided"
	help
fi

if [ "${isarchivelocprovided}" != "true" ];then
	echo "Option -archiveLoc must be provided"
	help
fi

SCRIPT_PATH=$(dirname "$0")
cd $SCRIPT_PATH

../../oui/bin/launch.sh -createCloneArchive ${argsarray}

exit $?
