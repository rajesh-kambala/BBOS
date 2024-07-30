@Echo off
Echo **********************************
Echo *        W A R N I N G           *  
Echo *                                * 
Echo * Executing this script will     *
Echo * copy files to the production   *
Echo * servers, update the production *
Echo * database, and deploy reports.  *
Echo *                                * 
Echo **********************************


ECHO 
ECHO ***
ECHO Recyle CRM2 CRM AppPool to free ReportInterface.dll
ECHO ***
ECHO 
Choice /C YN /D N /T 10 /M "Are you sure you want to deploy to production?"
IF ERRORLEVEL 2 GOTO Exit
IF ERRORLEVEL 1 GOTO Deploy


:Deploy
time /t
nant.exe -buildfile:.\DeployToCRM2.build -logfile:.\\DeployToCRM2.txt
time /t


:Exit
Pause


