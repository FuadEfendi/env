#!/bin/sh
if [ "X$SAVE_MEMORY" != Xtrue ]
then
  JAVA_OPTIONS="$JAVA_OPTIONS -Dweblogic.utils.cmm.lowertier.ServiceDisabled=true"
fi
