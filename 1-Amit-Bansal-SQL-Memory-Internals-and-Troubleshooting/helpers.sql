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

-- Clerks answer quite a lot

select type, name, memory_node_id, pages_kb/1204 as pages_mb, pages_kb, virtual_memory_reserved_kb, virtual_memory_committed_kb from sys.dm_os_memory_clerks
order by pages_kb desc

-- Buffer Pool

SELECT  SUM(pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb)/1024 AS [Used by BPool, MB]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';


-- Cache Stores

select name, type, pages_kb/1024 as pages_mb, pages_kb, entries_count from sys.dm_os_memory_cache_counters
order by pages_kb desc

--DBCC FREEPROCCACHE
