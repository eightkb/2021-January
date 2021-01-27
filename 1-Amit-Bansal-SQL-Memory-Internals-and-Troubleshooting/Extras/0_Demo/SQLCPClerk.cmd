@Echo Off
ECHO Preparing the demo environment...

REM - Get current directory
SET SUBDIR=%~dp0
SQLCMD -S.\SQl2014 -E -i %SUBDIR%SQLCPClerk.sql 
exit