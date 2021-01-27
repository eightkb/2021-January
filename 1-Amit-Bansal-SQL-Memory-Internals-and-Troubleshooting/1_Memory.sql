-- currently allocated & reserved memory
SELECT 
  physical_memory_in_use_kb/1024 AS sql_physical_memory_in_use_MB, 
	large_page_allocations_kb/1024 AS sql_large_page_allocations_MB, 
	locked_page_allocations_kb/1024 AS sql_locked_page_allocations_MB,
	virtual_address_space_reserved_kb/1024 AS sql_VAS_reserved_MB, 
	virtual_address_space_committed_kb/1024 AS sql_VAS_committed_MB, 
	virtual_address_space_available_kb/1024 AS sql_VAS_available_MB,
	page_fault_count AS sql_page_fault_count,
	memory_utilization_percentage AS sql_memory_utilization_percentage, 
	process_physical_memory_low AS sql_process_physical_memory_low, 
	process_virtual_memory_low AS sql_process_virtual_memory_low
FROM sys.dm_os_process_memory;


-- process memory consumption & details
select physical_memory_in_use_kb/1024 as physical_memory_in_use_MB,
large_page_allocations_kb/1024 as large_page_allocations_MB,
locked_page_allocations_kb/1204 as locked_page_allocations_MB,
total_virtual_address_space_kb/1024 as total_virtual_address_space_MB,
virtual_address_space_reserved_kb/1024 as virtual_address_space_reserved_MB,
virtual_address_space_committed_kb/1024 as virtual_address_space_committed_MB,
virtual_address_space_available_kb/1024 as virtual_address_space_available_MB,
available_commit_limit_kb/1024 as available_commit_limit_MB 
from sys.dm_os_process_memory


select * from sys.dm_os_nodes
--An internal component named the SQLOS creates node structures that mimic hardware processor locality. These structures can be changed by using soft-NUMA to create custom node layouts. 

-- Memory nodes
select target_kb/1024/1024 as Target_GB, memory_node_id,virtual_address_space_reserved_kb/1024/1024 as VAS_Reserved_GB, virtual_address_space_committed_kb/1024 as VAS_Committed_MB, locked_page_allocations_kb, pages_kb/1204 as Pages_MB, shared_memory_reserved_kb, shared_memory_committed_kb, cpu_affinity_mask,online_scheduler_mask, processor_group, foreign_committed_kb from sys.dm_os_memory_nodes

select * from  sys.dm_os_memory_clerks

select * from sys.dm_os_memory_objects

--select * from sys.dm_os_memory_allocations
--select distinct type from  sys.dm_os_memory_clerks

--select * from  sys.dm_os_memory_clerks
--where memory_node_id = 0

--select * from  sys.dm_os_memory_clerks
--where memory_node_id = 64


SELECT  SUM(pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb)/1024 AS [Used by BPool, MB]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';

--Get Buffer pool utilization by each database
SELECT DBName = CASE WHEN database_id = 32767 THEN 'RESOURCEDB' 
				ELSE DB_NAME(database_id) END,
	Size_MB = COUNT(1)/128
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY 2 DESC

--Get Buffer pool utilization  by each object in a database
USE AdventureWorks2016
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

-- lets run some queries

use AdventureWorks2016
go

select * from sales.SalesOrderHeader
select * from sales.SalesOrderDetail

-- go back and run the db & object queries again

-- lets do some more internals

select * from sys.dm_os_memory_clerks
where type = 'CACHESTORE_PHDR'

select * from sys.dm_os_memory_objects

select b.type as clerk, b.pages_kb,a.type as object,* from sys.dm_os_memory_objects a,sys.dm_os_memory_clerks b
where a.page_allocator_address=b.page_allocator_address
and b.type = 'CACHESTORE_PHDR'
order by
b.pages_kb DESC

select (sum(pages_in_bytes))/1024 as total from sys.dm_os_memory_objects
where type = 'MEMOBJ_PARSE'

select (sum(pages_in_bytes)+106496)/1024 as total from sys.dm_os_memory_objects
where type = 'MEMOBJ_PARSE'


-- Clerks answer quite a lot

select type, name, memory_node_id, pages_kb/1204 as pages_mb, pages_kb, virtual_memory_reserved_kb, virtual_memory_committed_kb from sys.dm_os_memory_clerks
order by pages_kb desc





















------------
--Clerks
-------------
select * from sys.dm_os_memory_clerks

-- clerks
-- breaks in 2012
SELECT [type],
memory_node_id,
single_pages_kb,
multi_pages_kb,
virtual_memory_reserved_kb,
virtual_memory_committed_kb,
awe_allocated_kb
FROM sys.dm_os_memory_clerks
ORDER BY virtual_memory_reserved_kb DESC ;

select DISTINCT type from sys.dm_os_memory_clerks


--------------
-- cache stores
-------------

select * from sys.dm_os_memory_cache_counters

SELECT [name],
[type],
single_pages_kb + multi_pages_kb AS total_kb,
entries_count
FROM sys.dm_os_memory_cache_counters
ORDER BY total_kb DESC ;



------------------
-- Buffer pool
-------------------

-- buffer pool

SELECT count(*)*8/1024 AS 'Cached Size (MB)'
,CASE database_id
WHEN 32767 THEN 'ResourceDb'
ELSE db_name(database_id)
END AS 'Database'
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY 'Cached Size (MB)' DESC




-----------
--objects
-----------
select * from sys.dm_os_memory_objects

select DISTINCT type from sys.dm_os_memory_objects


-- this breaks in 2012
select * from sys.dm_os_memory_clerks
order by single_pages_kb DESC


-- this breaks in 2012
select * from sys.dm_os_memory_clerks
order by multi_pages_kb DESC


--Below query can be used to determine
--actual memory consumption by SQL Server in MTL. 


select sum(multi_pages_kb) from sys.dm_os_memory_clerks


-- in 2012
select pages_kb as pages_kb_, * from sys.dm_os_memory_clerks
order by pages_kb_ DESC


select type, virtual_memory_committed_kb as a, * from sys.dm_os_memory_clerks
order by virtual_memory_committed_kb DESC

select * from sys.dm_os_performance_counters
where counter_name like '%mem%'


select * from sys.dm_os_memory_clerks
where type = 'MEMORYCLERK_SQLBUFFERPOOL'


select *
from sys.dm_os_sys_memory

------------


select physical_memory_in_use_kb/1024 as physical_memory_in_use_MB,
large_page_allocations_kb/1024 as large_page_allocations_MB,
locked_page_allocations_kb/1204 as locked_page_allocations_MB,
total_virtual_address_space_kb/1024 as total_virtual_address_space_MB,
virtual_address_space_reserved_kb/1024 as virtual_address_space_reserved_MB,
virtual_address_space_committed_kb/1024 as virtual_address_space_committed_MB,
virtual_address_space_available_kb/1024 as virtual_address_space_available_MB,
available_commit_limit_kb/1024 as available_commit_limit_MB 
from sys.dm_os_process_memory

---------------


select * 
from sys.dm_os_process_memory

--VAS summary

WITH VASummary(Size,Reserved,Free) AS 
(SELECT 
    Size = VaDump.Size, 
    Reserved =  SUM(CASE(CONVERT(INT, VaDump.Base)^0) 
    WHEN 0 THEN 0 ELSE 1 END), 
    Free = SUM(CASE(CONVERT(INT, VaDump.Base)^0) 
    WHEN 0 THEN 1 ELSE 0 END) 
FROM 
( 
    SELECT  CONVERT(VARBINARY, SUM(region_size_in_bytes)) 
    AS Size, region_allocation_base_address AS Base 
    FROM sys.dm_os_virtual_address_dump  
    WHERE region_allocation_base_address <> 0x0 
    GROUP BY region_allocation_base_address  
 UNION   
    SELECT CONVERT(VARBINARY, region_size_in_bytes), region_allocation_base_address 
    FROM sys.dm_os_virtual_address_dump 
    WHERE region_allocation_base_address  = 0x0 
) 
AS VaDump 
GROUP BY Size)

SELECT SUM(CONVERT(BIGINT,Size)*Free)/1024 AS [Total avail mem, KB] ,CAST(MAX(Size) AS BIGINT)/1024 AS [Max free size, KB]  
FROM VASummary  
WHERE Free <> 0 


--VAS consumers
-- this breaks in 2012
SELECT type, virtual_memory_committed_kb, multi_pages_k
FROM sys.dm_os_memory_clerks 
WHERE virtual_memory_committed_kb > 0 OR multi_pages_kb > 0 

-- in 2012

SELECT type, virtual_memory_committed_kb, pages_kb
FROM sys.dm_os_memory_clerks 
WHERE virtual_memory_committed_kb > 0 OR pages_kb > 0 




---------------------

--script 1
-- For example, you can use the following DMV query to find the 
-- total amount of memory consumed (including AWE) by 
-- the buffer pool:
-- breaks in 2012
SELECT  SUM(multi_pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb)/1024 AS [Used by BPool, MB]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';

-- in 2012
SELECT  SUM(pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb)/1024 AS [Used by BPool, MB]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';



--check the dirty pages..


SELECT db_name(database_id) AS 'Database',count(page_id) AS 'Dirty Pages'
FROM sys.dm_os_buffer_descriptors
WHERE is_modified =1
GROUP BY db_name(database_id)
ORDER BY count(page_id) DESC


-- clerks
-- breaks in 2012
SELECT [type],
memory_node_id,
single_pages_kb,
multi_pages_kb,
virtual_memory_reserved_kb,
virtual_memory_committed_kb,
awe_allocated_kb
FROM sys.dm_os_memory_clerks
ORDER BY virtual_memory_reserved_kb DESC ;

-- in 2012
SELECT [type],
memory_node_id,
pages_kb,
virtual_memory_reserved_kb,
virtual_memory_committed_kb,
awe_allocated_kb
FROM sys.dm_os_memory_clerks
ORDER BY virtual_memory_reserved_kb DESC ;




-- cache
-- breaks in 2012
SELECT [name],
[type],
single_pages_kb + multi_pages_kb AS total_kb,
entries_count
FROM sys.dm_os_memory_cache_counters
ORDER BY total_kb DESC ;

-- in 2012
SELECT [name],
[type],
pages_kb AS total_kb,
entries_count
FROM sys.dm_os_memory_cache_counters
ORDER BY total_kb DESC ;


-- buffer pool

SELECT count(*)*8/1024 AS 'Cached Size (MB)'
,CASE database_id
WHEN 32767 THEN 'ResourceDb'
ELSE db_name(database_id)
END AS 'Database'
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY 'Cached Size (MB)' DESC


-- plan cache

SELECT count(*) AS 'Number of Plans',
sum(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Plan Cache Size (MB)'
FROM sys.dm_exec_cached_plans



--plan cache size by cached object type:


SELECT objtype AS 'Cached Object Type',
count(*) AS 'Number of Plans',
sum(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Plan Cache Size (MB)',
avg(usecounts) AS 'Avg Use Count'
FROM sys.dm_exec_cached_plans
group by objtype



-- free system cache

DBCC FREESYSTEMCACHE('SQL Plans')

-- memory grant in query

--Granted Workspace Memory (KB): Total amount of query memory currently in use

--Maximum Workspace Memory (KB): Total amount of memory that SQL Server has marked
--for query memory

--Memory Grants Pending: Number of memory grants waiting in the queue

--Memory Grants Outstanding: Number of memory grants currently in use