/*============================================================================
  Summary:  Demonstrates how Transaction Log Auto Growth leads to blocking
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, www.SQLpassion.at

  For more scripts and sample code, check out 
    http://www.SQLpassion.at

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE master
GO

-- Create a new database with 10 GB Auto Growth for the Transaction Log
CREATE DATABASE AutoGrowthTransactionLog ON PRIMARY 
(
	NAME = N'AutoGrowthTransactionLog', 
	FILENAME = N'G:\MSSQL12.MSSQLSERVER\MSSQL\DATA\AutoGrowthTransactionLog.mdf',
	SIZE = 5120KB, 
	FILEGROWTH = 1024KB
)
LOG ON 
(
	NAME = N'AutoGrowthTransactionLog_log',
	FILENAME = N'G:\MSSQL12.MSSQLSERVER\MSSQL\DATA\AutoGrowthTransactionLog_log.ldf',
	SIZE = 1024KB,
	FILEGROWTH = 50GB -- 50 GB Auto Growth!
)
GO

-- Use the database
USE AutoGrowthTransactionLog
GO

-- Create a new table, every records needs a page of 8kb
CREATE TABLE Chunk
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 CHAR(8000)
)
GO

-- Insert 69 records into the table
-- This will trigger an Auto Growth operation of the Transaction Log
BEGIN TRANSACTION
GO

INSERT INTO Chunk VALUES (REPLICATE('x', 8000))
GO 69

-- Commit the Transaction from the current session
COMMIT TRANSACTION
GO

-- 1. Insert another record into the table (in a different session!)
-- This will take now around 10sec, because the Transaction Log has to grow
-- This will also block all other data modifications for this database.
INSERT INTO AutoGrowthTransactionLog.dbo.Chunk VALUES (REPLICATE('x', 8000))
GO

-- 2. Run these statements concurrently to the previous statement to analyze the blocking
-- that occurs, when the Auto Growth of the Transaction Log kicks in
-- The Auto Growth session reports the preemptive wait "PREEMPTIVE_OS_WRITEFILEGATHER",
-- and the pending data modification session reports the wait "LATCH_EX".
-- The data modification session waits itself on the latch "LOG_MANAGER" (sys.dm_os_latch_stats)
SELECT wait_type, * FROM sys.dm_exec_requests
WHERE session_id IN (52, 54)

SELECT wait_type, * FROM sys.dm_os_waiting_tasks
WHERE session_id IN (52, 54)
GO

-- Review the latch stats of the LOG_MANAGER
SELECT * FROM sys.dm_os_latch_stats
WHERE latch_class = 'LOG_MANAGER'
GO

-- Clean up
USE master
GO

DROP DATABASE AutoGrowthTransactionLog
GO