/*============================================================================
  Summary:  Demonstrates how to resolve Latch Contention with a Random
			Clustered Key Value or with In-Memory OLTP.
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

-- Create new database
CREATE DATABASE LatchContention
GO

USE LatchContention
GO

-- Let's create a traditional disk-based table
CREATE TABLE OrdersDiskBased
(
	OrderID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY CLUSTERED,
	CustomerID INT NOT NULL,
	ProductID INT NOT NULL,
	Quantity INT NOT NULL,
	Price DECIMAL(18, 2) NOT NULL
)
GO

-- Create a stored procedure that inserts 10000 new orders
CREATE PROCEDURE CreateOrdersDiskBased
AS
BEGIN
	DECLARE @i INT = 0
	BEGIN TRANSACTION

	WHILE (@i < 10000)
	BEGIN		
		INSERT INTO OrdersDiskBased (CustomerID, ProductID, Quantity, Price)
		VALUES
		(
			1, 
			1, 
			1,
			20.45
		)

		SET @i += 1
	END

	COMMIT TRANSACTION
END
GO

-- Clears the wait statistics
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)
GO

-- Execute the stored procedure with 100 parallel users
-- This takes around 1:30min
-- ostress.exe -S"localhost" -Q"EXEC LatchContention.dbo.CreateOrdersDiskBased" -n100 -r1 -q

-- Retrieve all current executing requests
SELECT wait_type, * FROM sys.dm_exec_requests
WHERE session_id > 50
GO

-- 1 000 000 records!
SELECT COUNT(*) FROM OrdersDiskBased
GO

-- Review the page latch waits on the object level
SELECT
	page_latch_wait_count, 
	page_latch_wait_in_ms,
	page_latch_wait_in_ms / page_latch_wait_count AS 'avg_waiting_time_ms',
	*
FROM sys.dm_db_index_operational_stats
(
	DB_ID('LatchContention'), 
	OBJECT_ID('OrdersDiskBased'), 
	NULL, 
	NULL
)
GO

-- Review the Page Latch wait types and WRITELOG
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%' OR wait_type = 'WRITELOG'
GO

-- ================================================================================
-- Resolve the Last Page Insert Latch Contention with a random Clustered Key Value
-- ================================================================================

-- Let's create a traditional disk-based table
CREATE TABLE OrdersDiskBasedGuid
(
	OrderID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY CLUSTERED,
	CustomerID INT NOT NULL,
	ProductID INT NOT NULL,
	Quantity INT NOT NULL,
	Price DECIMAL(18, 2) NOT NULL
)
GO

-- Create a stored procedure that inserts 10000 new orders
CREATE PROCEDURE CreateOrdersDiskBasedGuid
AS
BEGIN
	DECLARE @i INT = 0
	BEGIN TRANSACTION

	WHILE (@i < 10000)
	BEGIN		
		INSERT INTO OrdersDiskBasedGuid (OrderID, CustomerID, ProductID, Quantity, Price)
		VALUES
		(
			NEWID(),
			1, 
			1, 
			1,
			20.45
		)

		SET @i += 1
	END

	COMMIT TRANSACTION
END
GO

-- Clears the wait statistics
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)
GO

-- Execute the stored procedure with 100 parallel users
-- This takes around 10sec
-- ostress.exe -S"localhost" -Q"EXEC LatchContention.dbo.CreateOrdersDiskBasedGuid" -n100 -r1 -q

-- Retrieve all current executing requests
SELECT wait_type, * FROM sys.dm_exec_requests
WHERE session_id > 50
GO

-- 1 000 000 records!
SELECT COUNT(*) FROM OrdersDiskBasedGuid
GO

-- Review the page latch waits on the object level
SELECT
	page_latch_wait_count, 
	page_latch_wait_in_ms,
	page_latch_wait_in_ms / page_latch_wait_count AS 'avg_waiting_time_ms',
	*
FROM sys.dm_db_index_operational_stats
(
	DB_ID('LatchContention'), 
	OBJECT_ID('OrdersDiskBasedGuid'), 
	NULL, 
	NULL
)
GO

-- Review the Page Latch wait types and WRITELOG
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%' OR wait_type = 'WRITELOG'
GO

-- ==================================================================
-- Resolve the Last Page Insert Latch Contention with In-Memory OLTP
-- ==================================================================

--Add MEMORY_OPTIMIZED_DATA filegroup to the database.
ALTER DATABASE LatchContention
ADD FILEGROUP InMemoryOLTPFileGroup CONTAINS MEMORY_OPTIMIZED_DATA
GO

-- Add a new file to the previous created file group
ALTER DATABASE LatchContention ADD FILE
(
	NAME = N'InMemoryOLTPContainer', 
	FILENAME = N'G:\MSSQL12.MSSQLSERVER\MSSQL\DATA\InMemoryOLTPContainer'
)
TO FILEGROUP [InMemoryOLTPFileGroup]
GO

-- Let's create a new Memory Optimized Table
CREATE TABLE OrdersInMemory
(
	OrderID INT IDENTITY (1, 1) NOT NULL,
	CustomerID INT NOT NULL,
	ProductID INT NOT NULL,
	Quantity INT NOT NULL,
	Price DECIMAL(18, 2) NOT NULL
	CONSTRAINT chk_PrimaryKey PRIMARY KEY NONCLUSTERED HASH (OrderID) WITH (BUCKET_COUNT = 1048576) 
) WITH (MEMORY_OPTIMIZED = ON)
GO

-- Create a stored procedure that inserts continuously new orders
CREATE PROCEDURE CreateOrdersInMemory
AS
BEGIN
	DECLARE @i INT = 0
	BEGIN TRANSACTION

	WHILE (@i < 10000)
	BEGIN		
		INSERT INTO OrdersInMemory (CustomerID, ProductID, Quantity, Price)
		VALUES
		(
			1, 
			1, 
			1,
			20.45
		)

		SET @i += 1
	END

	COMMIT TRANSACTION
END
GO

-- Clears the wait statistics
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)
GO

-- Execute the stored procedure with 100 parallel users
-- This takes around 4sec
-- ostress.exe -S"localhost" -Q"EXEC LatchContention.dbo.CreateOrdersInMemory" -n100 -r1 -q

-- Retrieve all current executing requests
SELECT wait_type, * FROM sys.dm_exec_requests
WHERE session_id > 50
GO

-- 1 000 000 records!
SELECT COUNT(*) FROM OrdersInMemory
GO

-- Review the Page Latch wait types and WRITELOG
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%' OR wait_type = 'WRITELOG'
GO

-- Drop the stored procedure
DROP PROCEDURE CreateOrdersInMemory
GO

-- Create a stored procedure that inserts continuously new orders
CREATE PROCEDURE CreateOrdersInMemory
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN
	ATOMIC WITH
	(
		TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = 'us_english'
	)

	DECLARE @i INT = 0

	WHILE (@i < 10000)
	BEGIN
		INSERT INTO dbo.OrdersInMemory (CustomerID, ProductID, Quantity, Price)
		VALUES
		(
			1, 
			1, 
			1,
			20.45
		)

		SET @i += 1
	END
END
GO

-- Clears the wait statistics
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)
GO

-- Execute the stored procedure with 100 parallel users
-- This takes around 1sec
-- ostress.exe -S"localhost" -Q"EXEC LatchContention.dbo.CreateOrdersInMemory" -n100 -r1 -q

SELECT COUNT(*) FROM OrdersInMemory
GO

-- Review the Page Latch wait types and WRITELOG
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%' OR wait_type = 'WRITELOG'
GO

-- Clean up
USE master
GO

DROP DATABASE LatchContention
GO