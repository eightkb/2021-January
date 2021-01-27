	IF OBJECT_ID('baseline..Memory_Grants') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[Memory_Grants]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[session_id] [smallint] NULL,
	[request_id] [int] NULL,
	[scheduler_id] [int] NULL,
	[dop] [smallint] NULL,
	[request_time] [datetime] NULL,
	[grant_time] [datetime] NULL,
	[requested_memory_kb] [bigint] NULL,
	[granted_memory_kb] [bigint] NULL,
	[required_memory_kb] [bigint] NULL,
	[used_memory_kb] [bigint] NULL,
	[max_used_memory_kb] [bigint] NULL,
	[query_cost] [float] NULL,
	[timeout_sec] [int] NULL,
	[resource_semaphore_id] [smallint] NULL,
	[queue_id] [smallint] NULL,
	[wait_order] [int] NULL,
	[is_next_candidate] [bit] NULL,
	[wait_time_ms] [bigint] NULL,
	[plan_handle] [varbinary](64) NULL,
	[sql_handle] [varbinary](64) NULL,
	[group_id] [int] NULL,
	[pool_id] [int] NULL,
	[is_small] [bit] NULL,
	[ideal_memory_kb] [bigint] NULL,
	[query_plan] [xml] NULL,
	[text] [nvarchar](max) NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

	INSERT Memory_Grants WITH (TABLOCK)
	SELECT 1,GETDATE(),
	[session_id]
      ,[request_id]
      ,[scheduler_id]
      ,[dop]
      ,[request_time]
      ,[grant_time]
      ,[requested_memory_kb]
      ,[granted_memory_kb]
      ,[required_memory_kb]
      ,[used_memory_kb]
      ,[max_used_memory_kb]
      ,[query_cost]
      ,[timeout_sec]
      ,[resource_semaphore_id]
      ,[queue_id]
      ,[wait_order]
      ,[is_next_candidate]
      ,[wait_time_ms]
      ,[plan_handle]
      ,[sql_handle]
      ,[group_id]
      ,[pool_id]
      ,[is_small]
      ,[ideal_memory_kb]
      ,QP.[query_plan]
      ,ST.[text]
  FROM sys.dm_exec_query_memory_grants MG
  CROSS APPLY sys.dm_exec_query_plan (MG.plan_handle) QP
  CROSS APPLY sys.dm_exec_sql_text (MG.sql_handle) ST
END
ELSE
BEGIN
	INSERT Memory_Grants WITH (TABLOCK)
	SELECT (select ISNULL (max(Memory_Grants.collection_id),0)+1 from Memory_Grants),GETDATE(),
	[session_id]
      ,[request_id]
      ,[scheduler_id]
      ,[dop]
      ,[request_time]
      ,[grant_time]
      ,[requested_memory_kb]
      ,[granted_memory_kb]
      ,[required_memory_kb]
      ,[used_memory_kb]
      ,[max_used_memory_kb]
      ,[query_cost]
      ,[timeout_sec]
      ,[resource_semaphore_id]
      ,[queue_id]
      ,[wait_order]
      ,[is_next_candidate]
      ,[wait_time_ms]
      ,[plan_handle]
      ,[sql_handle]
      ,[group_id]
      ,[pool_id]
      ,[is_small]
      ,[ideal_memory_kb]
      ,QP.[query_plan]
      ,ST.[text]
  FROM sys.dm_exec_query_memory_grants MG
  CROSS APPLY sys.dm_exec_query_plan (MG.plan_handle) QP
  CROSS APPLY sys.dm_exec_sql_text (MG.sql_handle) ST
END
