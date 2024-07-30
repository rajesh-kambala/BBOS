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

Choice /C:YN /T:N,10 Are you sure you want to deploy to production?
IF ERRORLEVEL 2 GOTO Exit
IF ERRORLEVEL 1 GOTO Deploy


:Deploy
time /t
nant.exe -buildfile:.\DeployToBBOS2.build -logfile:.\\DeployToBBOS2.txt
time /t


:Exit
Pause


