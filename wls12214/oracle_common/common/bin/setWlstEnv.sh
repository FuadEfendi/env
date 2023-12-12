#!/bin/sh
if [ -z "${MW_HOME}" ]; then
  MW_HOME=
fi
export MW_HOME
. ${MW_HOME}/oracle_common/common/bin/setWlstEnv_internal.sh
