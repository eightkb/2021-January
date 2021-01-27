select session_id, memory_usage from sys.dm_exec_sessions
order by memory_usage desc