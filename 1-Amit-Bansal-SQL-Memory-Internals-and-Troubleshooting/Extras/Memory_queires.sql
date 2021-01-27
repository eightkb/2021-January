-- process memory consumption
select physical_memory_in_use_kb/1024 as physical_memory_in_use_MB,
large_page_allocations_kb/1024 as large_page_allocations_MB,
locked_page_allocations_kb/1204 as locked_page_allocations_MB,
total_virtual_address_space_kb/1024 as total_virtual_address_space_MB,
virtual_address_space_reserved_kb/1024 as virtual_address_space_reserved_MB,
virtual_address_space_committed_kb/1024 as virtual_address_space_committed_MB,
virtual_address_space_available_kb/1024 as virtual_address_space_available_MB,
available_commit_limit_kb/1024 as available_commit_limit_MB 
from sys.dm_os_process_memory

-- buffer pool


-- in 2012
SELECT  SUM(pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb)/1024 AS [Used by BPool, MB]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';

-- procedure cache

SELECT count(*) AS 'Number of Plans',
sum(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Plan Cache Size (MB)'
FROM sys.dm_exec_cached_plans
GO


-- VAS demo
-- open VAS demo file..

-- check VAS
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

SELECT SUM(CONVERT(BIGINT,Size)*Free)/1024/1024 AS [Total avail mem, MB] ,CAST(MAX(Size) AS BIGINT)/1024/1024 AS [Max free size, MB]  
FROM VASummary  
WHERE Free <> 0
GO