CREATE OR ALTER PROCEDURE ShipmentDetailsbyClient (@ClientID int)
AS

SELECT s.ReferenceNumber, sd.NumberOfContainers, sd.Mass, sd.Volume
	FROM ShipmentsColumnStore s
		INNER JOIN ShipmentDetails sd on s.ShipmentID = sd.shipmentID
	WHERE s.ClientID = @ClientID
GO

EXEC ShipmentDetailsbyClient 56
GO
