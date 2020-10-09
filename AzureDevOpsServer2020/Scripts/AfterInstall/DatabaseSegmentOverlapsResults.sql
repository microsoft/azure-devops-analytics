DECLARE @partitionsWithColumnStoreIndexes TABLE (partition_number int, ColumnStoreIndexName nvarchar(256), TableName nvarchar(256), IsActive BIT)
DECLARE @partitionsWithColumnStoreMetadata TABLE (partition_number int, ColumnStoreIndexName nvarchar(256), TableName nvarchar(256), IsActive BIT, KeyColumn NVARCHAR(50))

INSERT INTO @PartitionsWithColumnStoreIndexes
EXEC [AnalyticsInternal].[prc_GetPartitionsWithColumnStoreIndexes]

INSERT INTO @partitionsWithColumnStoreMetadata
SELECT csi.partition_number, 
	   f.IndexName, 
	   f.TableName, 
	   csi.IsActive, 
	   f.KeyColumn 
FROM [AnalyticsInternal].[func_iGetTableMaintenanceDefinitions] () f
INNER JOIN @PartitionsWithColumnStoreIndexes csi
ON csi.ColumnStoreIndexName = f.IndexName
AND csi.TableName = f.TableName

DECLARE @partitionsWithColumnStoreMetadataCursor CURSOR
DECLARE @partitionNumber NVARCHAR(256)
DECLARE @columnStoreIndexName NVARCHAR(256)
DECLARE @tableName NVARCHAR(256)
DECLARE @OverlapsData TABLE (DBName nvarchar(256), partition_number int, partitionId int, Overlaps int, SegmentsInPartition bigint, TableName nvarchar(256))
DECLARE @columnName NVARCHAR(256);

SET @partitionsWithColumnStoreMetadataCursor = CURSOR LOCAL FORWARD_ONLY STATIC FOR
(
    SELECT partition_number, ColumnStoreIndexName, TableName, KeyColumn FROM @partitionsWithColumnStoreMetadata
)

OPEN @partitionsWithColumnStoreMetadataCursor
FETCH NEXT FROM @partitionsWithColumnStoreMetadataCursor INTO @partitionNumber, @columnStoreIndexName, @tableName, @columnName;

WHILE @@FETCH_STATUS = 0
BEGIN
	--Getting overlaps data
	INSERT INTO @OverlapsData
    EXEC [AnalyticsInternal].[prc_GetOverlapPerSegmentsInPartition] @partitionNumber = @partitionNumber, @tableName = @tableName, @columnName = @columnName
	
    FETCH NEXT FROM @partitionsWithColumnStoreMetadataCursor INTO @partitionNumber, @columnStoreIndexName, @tableName, @columnName;
END

CLOSE @partitionsWithColumnStoreMetadataCursor
DEALLOCATE @partitionsWithColumnStoreMetadataCursor

select * from @OverlapsData