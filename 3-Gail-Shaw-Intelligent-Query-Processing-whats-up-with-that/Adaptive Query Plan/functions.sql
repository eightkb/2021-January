ALTER FUNCTION ShipmentTotal (@MinimumContainers INT)
RETURNS @ShipmentTotals TABLE (ClientID INT, ShipmentID int, Priority TINYINT, ReferenceNumber CHAR(25), TotalMass numeric(8,2), TotalVolume numeric(8,2), TotalContainers int)
AS
BEGIN

	INSERT INTO @ShipmentTotals
	SELECT s.ClientID, s.ShipmentID, s.Priority, s.ReferenceNumber,
		SUM(Mass) AS TotalMass, SUM(Volume) AS TotalVolume, SUM(NumberOfContainers) AS TotalContainers 
		FROM dbo.Shipments s
			INNER JOIN dbo.ShipmentDetails sd ON sd.ShipmentID = s.ShipmentID
		GROUP BY s.ClientID, s.ShipmentID, s.Priority, s.ReferenceNumber
		HAVING SUM(NumberOfContainers) >= @MinimumContainers

	RETURN

END
GO

SELECT c.LegalName,
       ss.OfficialName,
       st.Priority,
	   st.ReferenceNumber,
       SUM(t.Amount) AS ShipmentTotal,
	   st.TotalMass,
	   st.TotalVolume,
	   st.TotalContainers
	FROM dbo.Clients c 
		INNER JOIN dbo.ShipmentTotal(1) st ON st.ClientID = c.ClientID 
		INNER JOIN dbo.Transactions t ON t.ReferenceShipmentID = st.ShipmentID
		INNER JOIN dbo.StarSystems ss ON ss.StarSystemID = c.HeadquarterSystemID
	WHERE st.Priority = 2 AND c.ClientID = 42
	GROUP BY c.LegalName,
             ss.OfficialName,
             st.Priority,
             st.ReferenceNumber,
             st.TotalMass,
             st.TotalVolume,
             st.TotalContainers;


