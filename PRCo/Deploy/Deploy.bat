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
rem nant.exe -buildfile:.\DeployToBBOS1.build -logfile:.\\DeployToBBOS1.txt
rem nant.exe -buildfile:.\DeployToCRM1.build -logfile:.\\DeployToCRM1.txt
rem nant.exe -buildfile:.\DeployToBHS1.build -logfile:.\\DeployToBHS1.txt
rem nant.exe -buildfile:.\DeployDatabase.build -logfile:.\\DeployDatabase.txt
nant.exe -buildfile:.\DeployReports.build -logfile:.\\DeployReports.txt
time /t


:Exit
Pause


