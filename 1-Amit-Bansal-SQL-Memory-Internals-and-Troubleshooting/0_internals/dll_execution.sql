
-- put the dll in c drive of the VM

-- Create  an extended stored procedure in SQL Server

exec sp_addextendedproc  'HeapLeak','C:\SQLMaestros\EightKB_Jan_2021\0_internals\HeapLeak.dll'


exec HeapLeak
GO 30



while 1=1
begin
exec HeapLeak
waitfor delay '00:00:01'
end