

CREATE OR ALTER PROCEDURE ShipmentTotalsByStation (@Priority INT)
AS

SELECT ClientID, Priority, ReferenceNumber, SUM(NumberOfContainers) as TotalContainers 
	FROM dbo.ShipmentsColumnStore s 
		INNER HASH JOIN ShipmentDetailsColumnStore sd on s.ShipmentID = sd.ShipmentDetailID
	WHERE s.Priority <= @Priority
	GROUP BY ClientID, Priority, ReferenceNumber
	ORDER BY s.Priority, s.ReferenceNumber;
GO


EXEC ShipmentTotalsByStation 0