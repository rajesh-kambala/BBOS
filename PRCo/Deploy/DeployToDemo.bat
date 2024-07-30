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

Choice /C YN /D N /T 10 /M "Are you sure you want to deploy to production?"
IF ERRORLEVEL 2 GOTO Exit
IF ERRORLEVEL 1 GOTO Deploy



:Deploy
time /t
nant.exe -buildfile:.\DeployToDemo.build -logfile:.\\DeployToDemo.txt
time /t


:Exit
Pause


