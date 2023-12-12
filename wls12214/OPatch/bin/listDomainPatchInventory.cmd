@ECHO OFF
SETLOCAL

:: Help detect
SET help=0
IF  [%1] == [-h]  (
SET help=1
) ELSE IF [%1] == [-help] (
SET help=1
)

IF [%help%] == [1] (
echo Syntax:  listDomainPatchInventory ^<domain_directory^>
echo Usage: This command provides the information about configured 
echo        actions and patches in the domain inventory.
exit /b
)


:: Get DOMAIN_HOME
IF  [%1] == []  (
	echo Please enter DOMAIN_HOME directory, e.g %~0 domain_home_directory
	exit /b
) ELSE (
  SET DOMAIN_HOME=%1
) 

:: Set classpath
SET SCRIPTPATH=%~dp0
FOR %%i IN ("%SCRIPTPATH%\..\modules") DO SET MODULES_DIR=%%~fsi
FOR %%i IN ("%SCRIPTPATH%\..\..\oracle_common\modules") DO SET ORACLE_COMMON_MODULES_DIR=%%~fsi
SET OPATCH_COMMON_API_CLASSPATH=%MODULES_DIR%\features\oracle.glcm.opatch.common.api.classpath.jar;%ORACLE_COMMON_MODULES_DIR%\internal\features\lib_jaxb_2.3.0.jar

:: Set java command
SET ORACLE_HOME=%SCRIPTPATH%\..\..\
SET JAVA_HOME=
CALL %ORACLE_HOME%\oui\bin\getProperty.cmd JAVA_HOME JAVA_HOME 
SET JAVA=%JAVA_HOME%\bin\java.exe

:: Run the utility to check config patch inventory
%JAVA% -cp %OPATCH_COMMON_API_CLASSPATH% oracle.glcm.opatch.common.utils.CheckConfigPatchInventory %DOMAIN_HOME%

