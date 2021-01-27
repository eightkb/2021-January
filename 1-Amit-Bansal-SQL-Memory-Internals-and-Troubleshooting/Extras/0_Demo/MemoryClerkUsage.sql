--SQL connection pool
select * from sys.dm_os_memory_clerks
where type = 'MEMORYCLERK_SQLCONNECTIONPOOL'
AND memory_node_id = 0

--SQL plans
select * from sys.dm_os_memory_clerks
where type = 'CACHESTORE_SQLCP'
AND memory_node_id = 0

--SQL query exec
select * from sys.dm_os_memory_clerks
where type = 'MEMORYCLERK_SQLQUERYEXEC'
AND memory_node_id = 0

select * from sys.dm_os_memory_clerks
order by pages_kb desc


--Lock Manager
select * from sys.dm_os_memory_clerks
where type = 'OBJECTSTORE_LOCK_MANAGER'
AND memory_node_id = 0