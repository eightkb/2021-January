/*============================================================================
  Summary:  Demonstrates Transaction Processing in In-Memory OLTP
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, www.SQLpassion.at

  For more information about SQL Server, check out my website
    http://www.SQLpassion.at
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

SET STATISTICS IO, TIME ON
GO

USE master
GO

-- ===================================
-- Creating a In-Memory OLTP Database
-- ===================================

-- Create new database
CREATE DATABASE InMemoryOLTP
GO

--Add MEMORY_OPTIMIZED_DATA filegroup to the database.
ALTER DATABASE InMemoryOLTP
ADD FILEGROUP InMemoryOLTPFileGroup CONTAINS MEMORY_OPTIMIZED_DATA
GO

USE InMemoryOLTP
GO

-- Add a new file to the previously created file group
ALTER DATABASE InMemoryOLTP ADD FILE
(
	NAME = N'InMemoryOLTPContainer', 
	FILENAME = N'G:\MSSQL12.MSSQLSERVER\MSSQL\DATA\InMemoryOLTPContainer'
)
TO FILEGROUP [InMemoryOLTPFileGroup]
GO

-- Create a new Memory Optimized Table
CREATE TABLE Persons
(
	PersonID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1024),
	FirstName VARCHAR(100) NOT NULL,
	LastName VARCHAR(100) NOT NULL
)
WITH
(
	MEMORY_OPTIMIZED = ON, 
	DURABILITY = SCHEMA_AND_DATA
)
GO

-- Insert some records
INSERT INTO Persons VALUES ('Klaus', 'Aschenbrenner')
INSERT INTO Persons VALUES ('Karin', 'Aschenbrenner')
INSERT INTO Persons VALUES ('Philip', 'Aschenbrenner')
INSERT INTO Persons VALUES ('Daniel', 'Aschenbrenner')
GO

-- This statement will fail, because the Transaction Isolation Level must be specified through a table hint
BEGIN TRANSACTION

SELECT * FROM Persons

COMMIT
GO

-- Let's specify the Transaction Isolation Level
BEGIN TRANSACTION

SELECT * FROM Persons WITH (SNAPSHOT)

COMMIT
GO

-- We can upgrade the Transaction Isolation Level to SNAPSHOT for all operations on Memory Optimized Tables
-- through the database option MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT.
ALTER DATABASE InMemoryOLTP
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT ON
GO

-- Now we don't need to specify explicitely the Transaction Isolation Level through a table hint.
BEGIN TRANSACTION

SELECT * FROM Persons

COMMIT
GO

-- ====================================
-- Demonstrates a Write-Write conflict
-- ====================================

-- Run this transaction across 2 sessions
BEGIN TRANSACTION

UPDATE Persons
SET FirstName = '...'
WHERE PersonID = 1

ROLLBACK
GO

-- ===================================
-- Demonstrates a Read-Write conflict
-- ===================================

-- 1st transaction
BEGIN TRANSACTION

-- We want to have Read Stability
SELECT * FROM Persons WITH (REPEATABLEREAD)

-- Before the commit, run the 2nd transaction in a different session
-- The Read-Set has changed, therefore we have a Repeatable Read Validation failure
COMMIT
GO

-- 2nd transaction
BEGIN TRANSACTION

UPDATE Persons
SET FirstName = 'Geeorge'
WHERE PersonID = 1

COMMIT
GO

-- Reset the column value
UPDATE Persons
SET FirstName = 'Klaus'
WHERE PersonID = 1
GO

-- ======================================
-- Demonstrates a SERIALIZABLE violation
-- ======================================

-- 1st transaction
BEGIN TRANSACTION

-- We want to have Read Stability and Phantom Avoidance
SELECT * FROM Persons WITH (SERIALIZABLE)

-- Before the commit, run the 2nd transaction in a different session
-- The Scan-Set has changed, therefore we have a Serializable Validation failure
COMMIT
GO

-- 2nd transaction
INSERT INTO Persons VALUES ('Jack', 'Bauer')
GO

-- Delete the prevíous inserted record
DELETE FROM Persons
WHERE FirstName = 'Jack'
AND LastName = 'Bauer'
GO

-- Drop the previous created table
DROP TABLE Persons
GO

-- ========================================
-- Demonstrates a SNAPSHOT violation error
-- ========================================

-- Create a simple Memory Optimized Table
CREATE TABLE Foo
(
	Col1 INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1024),
	Col2 VARCHAR(100) NOT NULL,
	Col3 VARCHAR(100) NOT NULL
)
WITH
(
	MEMORY_OPTIMIZED = ON, 
	DURABILITY = SCHEMA_AND_DATA
)
GO

-- 1st transaction
BEGIN TRANSACTION

INSERT INTO Foo VALUES (1, 'abc', 'def')

-- Before the commit, run the *same* INSERT statement in a different session.
-- This will give you a Serializable Validation failure, because of the duplicate primary key.
COMMIT
GO

-- Drop the previous created table
DROP TABLE Foo
GO

-- Clean up
USE master
GO

DROP DATABASE InMemoryOLTP
GO