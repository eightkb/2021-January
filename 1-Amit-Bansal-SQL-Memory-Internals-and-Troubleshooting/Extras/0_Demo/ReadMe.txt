Monitor SQL Connection Pool Clerk

1.	Open SQL Server Configuration Manager and select SQL Server Services in the left pane.
2.	In the right pane right click on SQL Server (MSSQLSERVER) and click restart. This will restart the SQL Server services and clears all memory.
3.	Open SQL Server Management Studio from start menu and connect to the default instance using windows authentication.
4.	Open the MemoryClerkUsage.sql Transact-SQL file from the folder D:\LabFiles\Lab04\Lab04B\Ex01\Starter.
5.	Select the code under the comment SQL connection pool and click Execute. In the Results pane, note the value under the column pages_kb.
6.	In the folder D:\LabFiles\Lab04\Lab04B\Ex01\Starter, right click on the file AddConnectionsClerk.cmd and click Run as administrator. This will open 143 SQLCMD connections to SQL Server. They will stay active for one minute, approximately.
7.	In MemoryClerkUsage.sql query window, select the code under the comment SQL connection pool and click Execute. Observe the value under the column pages_kb increases while the SQLCMD connections are active.
8.	After all SQLCMD connections from step 6 have completed execution after a minute, repeat step 7. Observe the value under the column pages_kb decreases to its original value noted in step 6.


Monitor SQL Plan Cache Clerk

1.	In MemoryClerkUsage.sql query window, select the code under the comment SQL plans and click Execute. Note the value under the column pages_kb.
2.	In the folder D:\LabFiles\Lab04\Lab04B\Ex01\Starter, right click on the file SQLCPClerk.cmd and click Run as administrator. This will run a workload for one minute approximately on AdventureWorks2014 database to generate random plans in the plan cache.
3.	After the execution completes, in MemoryClerkUsage.sql query window, select the code under the comment SQL plans and click Execute. Observe the value under the column pages_kb increases.



Monitor SQL Query Execution Clerk

1.	In MemoryClerkUsage.sql query window, select the code under the comment SQL query exec and click Execute. Note the value under the column pages_kb.
2.	Open the QueryExecClerk.sql Transact-SQL file from the folder D:\LabFiles\Lab04\Lab04B\Ex01\Starter and click Execute.
3.	While the QueryExecClerk.sql is executing, in MemoryClerkUsage.sql query window, select the code under the comment SQL query exec and click Execute. Observe the value under the column pages_kb increases.
4.	In QueryExecClerk.sql query window press Alt + Break to stop the execution of the query.Close QueryExecClerk.sql query window.


Monitor Lock Manager Clerk

1.	In MemoryClerkUsage.sql query window, select the code under the comment Lock Manager and click Execute. Note the value under the column pages_kb.
2.	Open the LockClerk.sql Transact-SQL file from the folder D:\LabFiles\Lab04\Lab04B\Ex01\Starter. Select the code under the comment Begin transaction and click Execute.
3.	In MemoryClerkUsage.sql query window, select the code under the comment Lock Manager and click Execute. Observe that the value under the column pages_kb increases.
4.	In LockClerk.sql query window, select the code under the comment roll back transaction and click Execute. 
5.	Close SQL Server Management Studio without saving any changes.


