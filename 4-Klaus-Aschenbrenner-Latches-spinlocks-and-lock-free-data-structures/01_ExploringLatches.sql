/*============================================================================
  Summary:  Demonstrates Latch Analysis
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, www.SQLpassion.at

  For more scripts and sample code, check out 
    http://www.SQLpassion.at

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Review the BUF-Latches
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
GO

-- Review the IO-Latches
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGEIOLATCH%'
GO

-- Review the Non-BUF Latches
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'LATCH%'
GO

-- Deailed breakdown of the Non-BUF Latches
SELECT * FROM sys.dm_os_latch_stats
GO