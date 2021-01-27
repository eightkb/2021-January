SET SUBDIR=%~dp0
SQLCMD -S. -E -i %SUBDIR%Workload.sql 
exit