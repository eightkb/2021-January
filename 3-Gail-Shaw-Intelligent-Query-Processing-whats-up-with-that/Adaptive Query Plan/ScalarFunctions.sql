CREATE OR ALTER FUNCTION dbo.DateOnly (@Input DATETIME)
  RETURNS DATETIME
AS
BEGIN
  RETURN DATEADD(dd, DATEDIFF (dd, 0, @Input), 0);
END
GO

SET STATISTICS TIME ON;
GO

SELECT DATEADD(dd, DATEDIFF (dd, 0, TransactionDate), 0) 
	FROM dbo.Transactions;



SELECT dbo.DateOnly(TransactionDate) 
	FROM dbo.Transactions;

