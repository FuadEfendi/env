#!/bin/sh

echo "**********************************************************************"
echo ""
echo "            Prerequisite for OPatch via OUI PrereqChecker            "
echo ""
echo "**********************************************************************"

echo "Enter the ORACLE_HOME to be checked:"
read ORACLE_HOME
echo "ORACLE_HOME to be checked is \"$ORACLE_HOME\""
echo ""
done=false;
MAX_CHOICE=5

echo "Press control-C at any time to quit"
while [ $done = false ]; do
	echo "(1) Check if a patch can be applied to ORACLE_HOME (oracle.opatch.apply)";
	echo "(2) Check if a patch can be rolled back from ORACLE_HOME (oracle.opatch.rollback)";
        echo "(3) Check for conflicts (oracle.opatch.conflict)";
        echo "(4) Check for RAC nodes (oracle.opatch.rac)";
        echo ""
        echo "Enter the number for the check you want to run: ";
	read choice
	if [ $choice -gt 0 ] && [ $choice -lt  $MAX_CHOICE ]; then

                #   Apply Check
                #
		if [ $choice -eq 1 ]; then
		   echo "Do you want to check 1 patch or many patches at the same time?"
                   echo "(1) to check a single patch"
		   echo "(2) to check multiple patches"

		   read applyChoice;
	           if [ $applyChoice -eq 1 ]; then
                      echo "Enter the patch location: ";
                      read patchLoc;
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME OPATCH_PATCH_LOCATION=$patchLoc \
                          -entryPoint "oracle.opatch.apply"
                   fi
                   if [ $applyChoice -eq 2 ]; then
                      echo "Enter the directory containing all the patches: ";
                      read patchLoc;
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME OPATCH_PATCH_BASE_DIR=$patchLoc \
                          -entryPoint "oracle.opatch.apply"
                   fi
		fi

                #   Rollback Check
                #
		if [ $choice -eq 2 ]; then
                   echo "Do you want to check 1 patch or many patches at the same time?"
                   echo "(1) to check a single patch"
                   echo "(2) to check multiple patches"

                   read rollbackChoice;
                   if [ $rollbackChoice -eq 1 ]; then
                      echo "Enter the patch ID: ";
                      read patchID;
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME OPATCH_PATCH_ID=$patchID \
                          -entryPoint "oracle.opatch.rollback"
                   fi
                   if [ $rollbackChoice -eq 2 ]; then
                      echo "Enter all the patch IDs separated by comma(,): ";
                      read patchLoc;
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME OPATCH_PATCH_ID=$patchID \
                          -entryPoint "oracle.opatch.rollback"
                   fi
		fi

                #   Conflict Check
                #
                if [ $choice -eq 3 ]; then
                   echo "Do you want to check 1 patch or many patches at the same time?"
                   echo "(1) to check a single patch (check if given patch has conflicts with patches installed in ORACLE_HOME"
                   echo "(2) to check multiple patches (check if given patches under given location have conflicts with " \
                        "patches installed in ORACLE_HOME"

                   read conflictChoice;
                   if [ $conflictChoice -eq 1 ]; then
                      echo "Enter the patch location: ";
                      read patchLoc;
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME OPATCH_PATCH_LOCATION=$patchLoc \
                          -entryPoint "oracle.opatch.conflict"
                   fi
                   if [ $conflictChoice -eq 2 ]; then
                      echo "Enter the directory containing all the patches: ";
                      read patchLoc;
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME OPATCH_PATCH_BASE_DIR=$patchLoc \
                          -entryPoint "oracle.opatch.conflict"
                   fi
                fi

                #   RAC Check
                #
                if [ $choice -eq 4 ]; then
                      $ORACLE_HOME/oui/bin/runInstaller -prereqchecker \
                          PREREQ_CONFIG_LOCATION=$ORACLE_HOME/OPatch/opatchprereqs \
                          ORACLE_HOME=$ORACLE_HOME \
                          -entryPoint "oracle.opatch.rac"
                fi

	else
                echo "Wrong choice.  Re-enter a number for the test you want to run."
	fi
done
