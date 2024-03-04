DROP TABLE IF EXISTS guamStaging.dbo.MigratedTableCounts
DROP TABLE IF EXISTS guamStaging.dbo.ConvTableCounts

GO
USE [JustWareMigrated_full]
SELECT 

      QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS [TableName]
      , SUM(sPTN.Rows) AS ocr
INTO churchillStaging.dbo.MigratedTableCounts
FROM 
      sys.objects AS sOBJ
      INNER JOIN sys.partitions AS sPTN
            ON sOBJ.object_id = sPTN.object_id
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
      AND index_id < 2 -- 0:Heap, 1:Clustered
GROUP BY 
      sOBJ.schema_id
      , sOBJ.name

--ORDER BY [TableName]
GO

USE churchilleCourtConv
SELECT 

      QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS [TableName]
      , SUM(sPTN.Rows) AS ocr
INTO churchillStaging.dbo.ConvTableCounts
FROM 
      sys.objects AS sOBJ
      INNER JOIN sys.partitions AS sPTN
            ON sOBJ.object_id = sPTN.object_id
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
      AND index_id < 2 -- 0:Heap, 1:Clustered
GROUP BY 
      sOBJ.schema_id
      , sOBJ.name

--ORDER BY [TableName]
GO

SELECT * FROM churchillStaging.dbo.MigratedTableCounts m
LEFT JOIN churchillStaging.dbo.ConvTableCounts c
ON m.TableName = c.TableName
WHERE m.ocr > 0 and c.ocr = 0;

