@ECHO OFF
SETLOCAL

:: Help detect
SET ALLARGS=%*

:: Set classpath
SET SCRIPTPATH=%~dp0

:: Set JAXB_VERSION
SET JAXB_VERSION=2.3.0
SET ORACLE_HOME=%SCRIPTPATH%..\..
SET JAXB_LOCATION=%ORACLE_HOME%
SET NEXTGEN=False
IF EXIST "%ORACLE_HOME%\oui\modules" (
	::NextGen OUI home check if 'modules' directory exists
  set NEXTGEN=True
	SET MODULES_DIR=%SCRIPTPATH%..\modules
	SET JAXB_LOCATION=%ORACLE_HOME%\oui\modules\private
) ELSE (
	::Not NextGen
	FOR %%i IN ("%SCRIPTPATH%\..\..\modules") DO SET MODULES_DIR=%%~fsi
	FOR %%i IN ("=%ORACLE_HOME%\OPatch\modules\internal\features") DO SET JAXB_LOCATION=%%~fsi
  
)

IF %NEXTGEN% == True (
 SET JAXB_CLASSPATH=%JAXB_LOCATION%\jaxb-core-%JAXB_VERSION%.jar;%JAXB_LOCATION%\jaxb-impl-%JAXB_VERSION%.jar;%JAXB_LOCATION%\jaxb-xjc-%JAXB_VERSION%.jar
) ELSE (
 SET JAXB_CLASSPATH=%JAXB_LOCATION%\lib_jaxb_%JAXB_VERSION%.jar
)

SET OPATCH_COMMON_API_CLASSPATH=%MODULES_DIR%\features\oracle.glcm.opatch.common.api.classpath.jar;%JAXB_CLASSPATH%


:: Set java command
SET JAVA_HOME=
CALL %ORACLE_HOME%\oui\bin\getProperty.cmd JAVA_HOME JAVA_HOME 
SET JAVA="%JAVA_HOME%\bin\java.exe"

:: Run ViewAliasInfo utility
%JAVA% -cp %OPATCH_COMMON_API_CLASSPATH% -DORACLE_HOME=%ORACLE_HOME% oracle.glcm.opatch.common.utils.ViewAliasInfo %ALLARGS%
SET RETURN_CODE=%ERRORLEVEL%
