CREATE OR ALTER FUNCTION dbo.Numbers2 (@StartNumber INT, @EndNumber INT)
RETURNS @Numbers TABLE (Number Int)
AS
BEGIN
WITH Generator(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),
GeneratedRows(N) AS (
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS i FROM Generator g1 CROSS JOIN Generator g2 CROSS JOIN Generator g3
)
	INSERT INTO @Numbers
	SELECT N FROM GeneratedRows WHERE N BETWEEN @StartNumber AND @EndNumber

	RETURN
END
GO


SELECT Num.Number FROM StarSystems ss CROSS APPLY dbo.Numbers2(1,100) Num;


