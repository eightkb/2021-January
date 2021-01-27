--Get Buffer pool from buffer_descriptors
select count(*)/128 from sys.dm_os_buffer_descriptors

-- --Get Buffer pool from clerk
SELECT pages_kb/1024 AS [Used by BPool, MB]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';


select b.type as clerk, b.pages_kb,a.type as object,* from sys.dm_os_memory_objects a,sys.dm_os_memory_clerks b
where a.page_allocator_address=b.page_allocator_address
and b.type = 'CACHESTORE_PHDR'
order by
b.pages_kb DESC

select * from sys.dm_os_memory_clerks
where type = 'CACHESTORE_PHDR'

select (sum(pages_in_bytes)+32768)/1024 as total from sys.dm_os_memory_objects
where type = 'MEMOBJ_PARSE'

select MC.type, MO.type, sum(MO.pages_in_bytes)/1024/1024 as Size_in_MB from sys.dm_os_memory_clerks MC
inner join sys.dm_os_memory_objects MO
on MO.page_allocator_address = MC.page_allocator_address
group by MC.type, MO.type
order by Size_in_MB DESC

select type, pages_kb/1024 as Size_In_MB from sys.dm_os_memory_clerks
where memory_node_id = 0
order by Size_In_MB desc

select * from sys.dm



select MC.type, MO.type from  sys.dm_os_memory_clerks MC
left outer join sys.dm_os_memory_objects MO
on MC.page_allocator_address = MO.page_allocator_address
--where MC.type = 'MEMORYCLERK_SQLBUFFERPOOL'


WITH	BPU
AS
(
	SELECT	DB_NAME(DOBP.database_id)	AS database_name,
			COUNT(*) / 128.0			AS CachedSize
	FROM	sys.dm_os_buffer_descriptors  DOBP WITH(NOLOCK)
	WHERE	DOBP.database_id NOT IN (1, 2, 3, 4, 32767)
	GROUP BY
			database_id
)
SELECT	ROW_NUMBER() OVER(ORDER BY CachedSize DESC)							AS [Buffer Pool Rank],
		BPU.database_name,
		CAST(CachedSize AS NUMERIC(18, 2))									AS [Cached Size (MB)],
		CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2))	AS [Buffer Pool Percent]
FROM	BPU
ORDER BY
		[Buffer Pool Rank] OPTION (RECOMPILE);
GO


