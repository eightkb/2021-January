declare @hdl int
exec sp_cursoropen @hdl OUTPUT, N'select * from sys.sysobjects',4,4,20
go