-- Setup

DROP TABLE IF EXISTS dbo.ShipmentsColumnStore
DROP TABLE IF EXISTS dbo.ShipmentDetailsColumnStore

SELECT * 
INTO ShipmentsColumnStore
FROM dbo.Shipments

SELECT * 
INTO ShipmentDetailsColumnStore
FROM dbo.ShipmentDetails
GO

CREATE CLUSTERED COLUMNSTORE INDEX idx_s ON dbo.ShipmentsColumnStore
CREATE CLUSTERED COLUMNSTORE INDEX idx_sd ON dbo.ShipmentDetailsColumnStore
GO


DBCC FREEPROCCACHE

