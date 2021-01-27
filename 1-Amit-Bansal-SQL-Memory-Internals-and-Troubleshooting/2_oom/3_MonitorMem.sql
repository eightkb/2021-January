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
GO

SELECT [type], 
	SUM(pages_in_bytes)/1024/1024 AS current_total_MB, SUM(max_pages_in_bytes)/1024/1024 AS max_total_MB 
FROM sys.dm_os_memory_objects 
GROUP BY [type]
ORDER BY current_total_MB DESC
GO

SELECT * FROM sys.dm_os_memory_clerks
ORDER BY pages_kb DESC