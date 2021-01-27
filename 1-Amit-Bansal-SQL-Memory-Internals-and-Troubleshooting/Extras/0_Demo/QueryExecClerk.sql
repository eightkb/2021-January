USE AdventureWorks2014;
GO

while (1=1)
begin
DBCC DROPCLEANBUFFERS
SELECT TOP(10000)
	a.*
FROM master..spt_values a, master..spt_values b
ORDER BY 
	a.number DESC, b.number DESC
end;
GO