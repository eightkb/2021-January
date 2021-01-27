-- Check Waiting Tasks...
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE 
	wait_type = 'RESOURCE_SEMAPHORE'
GO


--Check Memory Grants
SELECT *
FROM sys.dm_exec_query_memory_grants
GO


-- Check Wait Stats
SELECT *
FROM sys.dm_os_wait_stats
WHERE 
	wait_type = 'RESOURCE_SEMAPHORE'
GO
