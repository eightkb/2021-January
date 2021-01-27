USE [msdb]
GO

/****** Object:  Job [Memory_Grants]    Script Date: 5/23/2013 2:49:49 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 5/23/2013 2:49:49 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Memory_Grants', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WIN2012R2\Administrator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [collect_memory_grants]    Script Date: 5/23/2013 2:49:50 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'collect_memory_grants', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'	IF OBJECT_ID(''baseline..Memory_Grants'') IS NULL
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
	
	--DBCC SQLPERF (N''sys.dm_os_wait_stats'', CLEAR); 

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
', 
		@database_name=N'baseline', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_15_sec', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130330, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd0040d59-d2ef-45bd-9f1b-ec9c4bee8b85'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


