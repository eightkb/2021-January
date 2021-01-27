--Begin transaction
Use AdventureWorks2014
GO

CREATE TABLE dbo.Customer
(COLA int IDENTITY (1,1), COLB INT)
GO

while 1=1
BEGIN
	INSERT dbo.Customer DEFAULT VALUES
	If @@IDENTITY = 5000
	BREAK;
END


BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA <=5000

-- roll back transaction
ROLLBACK TRAN

