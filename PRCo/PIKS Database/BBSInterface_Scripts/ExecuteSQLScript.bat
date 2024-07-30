@echo off
echo.
echo Execute %5 Scripts
sqlcmd -S %1 -d %2 -U %3 -P %4 -i "%~5.sql" -o "%~5.sql.txt"
type "%~5.sql.txt"
echo.
