CREATE OR ALTER FUNCTION dbo.ShipmentMass(@ShipmentID INT)
RETURNS NUMERIC(20,4)
AS
BEGIN
    DECLARE @ShipmentMass NUMERIC(20,4);
    SELECT @ShipmentMass = SUM(Mass) FROM dbo.ShipmentDetails sd WHERE sd.ShipmentID = @ShipmentID;
 
    RETURN @ShipmentMass;
 
END
GO

SET STATISTICS TIME, IO ON;

SELECT s.ShipmentID, 
    (SELECT SUM(Mass) AS TotalMass FROM dbo.ShipmentDetails sd WHERE sd.ShipmentID = s.ShipmentID) TotalShipmentMass
FROM dbo.Shipments s;
GO



SELECT s.ShipmentID, dbo.ShipmentMass(s.ShipmentID) TotalShipmentMass
FROM dbo.Shipments s;
GO

