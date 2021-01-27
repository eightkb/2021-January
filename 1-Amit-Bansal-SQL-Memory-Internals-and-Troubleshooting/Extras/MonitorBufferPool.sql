--Get Buffer pool utilization by each database
SELECT DBName = CASE WHEN database_id = 32767 THEN 'RESOURCEDB' 
				ELSE DB_NAME(database_id) END,
	Size_MB = COUNT(1)/128
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY 2 DESC

--Get Buffer pool utilization  by each object in a database
USE AdventureWorks2014
GO
SELECT DBName = CASE WHEN database_id = 32767 THEN 'RESOURCEDB' 
				ELSE DB_NAME(database_id) END,
	ObjName = o.name,
	Size_MB = COUNT(1)/128.0
FROM sys.dm_os_buffer_descriptors obd
INNER JOIN sys.allocation_units au
	ON obd.allocation_unit_id = au.allocation_unit_id
INNER JOIN sys.partitions p
	ON au.container_id = p.hobt_id
INNER JOIN sys.objects o
	ON p.object_id = o.object_id
WHERE obd.database_id = DB_ID()
AND o.type != 'S'
GROUP BY obd.database_id, o.name
ORDER BY 3 DESC

--Get clean and dirty pages count in a database
USE AdventureWorks2014
GO
SELECT Page_Status = CASE WHEN is_modified = 1 THEN 'Dirty' 
				ELSE 'Clean' END,
	DBName = CASE WHEN database_id = 32767 THEN 'RESOURCEDB' 
				ELSE DB_NAME(database_id) END,
	Pages = COUNT(1)
FROM sys.dm_os_buffer_descriptors
WHERE database_id = DB_ID()
GROUP BY database_id, is_modified
ORDER BY 2

--clear clean pages
DBCC DROPCLEANBUFFERS()
GO

--Run Checkpoint
CHECKPOINT