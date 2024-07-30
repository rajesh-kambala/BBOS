@echo off
cls
echo ***********************************************
echo * Create PRCo BBSInterface  Tables and Fields *
echo * Travant Solutions, Inc.                     *
echo ***********************************************
echo.
echo Server: %1
echo Database: %2
echo Username: %3
echo Scripts Dir: %5


:begin
if "%1"=="" goto usage
if "%2"=="" goto usage
if "%3"=="" goto usage
if "%4"=="" goto usage
if "%~5"=="" goto usage


:Go
echo.
echo Delete any previous output files...
del "%~5\*.sql.txt" /q



echo. 
echo Execute PRCo BBSInterface Database Creation Scripts...

call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\GeneralFunctions"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\Interface"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateAddress"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateAffil"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateBrands"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateChangeDetection"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateClassIf"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateClassVal"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateCmdVal"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateCommod"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateCompany"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateEBBUpdate"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateInternet"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateLicense"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateListing"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePersaff"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePerson"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePhone"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePRPubAddr"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePRService"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePRServiceAlaCarte"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePRServicePayment"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateRating"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateSupply"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateSuppVal"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateTowns"

call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulateBBSInterface"
call ExecuteSQLScript.bat %1 %2 %3 %4 "%~5\PopulatePIKS"

echo.  
echo PRCo BBSInterface Database Creation Scripts Completed...
echo.  
echo.  


:goFooter
echo.
echo Finished executing scripts.  
echo Check output text files to determine if SQL executed succesfully
goto exit

:Usage
echo Invalid parameter specified
echo Usage:
echo PRCo Build BBSInterface Database.bat [SQL Server Instance] [Database] [user ID] [Password] [SQL Script Path] 
echo Example: PRCo Build BBSInterface Database.bat MySQLServer pubs user password ".\"

:exit
echo.
