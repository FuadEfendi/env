@rem *************************************************************************
@rem This script is used to initialize common environment to start WebLogic
@rem Server, as well as WebLogic development.
@rem *************************************************************************

IF NOT DEFINED MW_HOME (
 IF NOT DEFINED WL_HOME (
  echo Please set MW_HOME or WL_HOME 
  IF DEFINED USE_CMD_EXIT (
   EXIT 1
  ) ELSE (
   EXIT /B 1
  )
 )
)

IF DEFINED WL_HOME (
 set MW_HOME=%WL_HOME%\..
) ELSE (
 set WL_HOME=%MW_HOME%\wlserver 
)
FOR %%i IN ("%MW_HOME%") DO SET MW_HOME=%%~fsi
FOR %%i IN ("%WL_HOME%") DO SET WL_HOME=%%~fsi

call %MW_HOME%/oracle_common/common/bin/commBaseEnv.cmd
call %MW_HOME%/oracle_common/common/bin/commExtEnv.cmd
