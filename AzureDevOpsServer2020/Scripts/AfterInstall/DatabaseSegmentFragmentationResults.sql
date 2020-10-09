DECLARE @PartitionsWithColumnStoreIndexes TABLE (partition_number int, ColumnStoreIndexName nvarchar(256), TableName nvarchar(256), IsActive BIT)
INSERT INTO @PartitionsWithColumnStoreIndexes
EXEC [AnalyticsInternal].[prc_GetPartitionsWithColumnStoreIndexes]


DECLARE @PartitionsWithColumnStoreIndexesCursor CURSOR
DECLARE @partitionNumber NVARCHAR(256)
DECLARE @columnStoreIndexName NVARCHAR(256)
DECLARE @tableName NVARCHAR(256)

SET @PartitionsWithColumnStoreIndexesCursor = CURSOR LOCAL FORWARD_ONLY STATIC FOR
(
    SELECT partition_number, ColumnStoreIndexName, TableName FROM @PartitionsWithColumnStoreIndexes
)

OPEN @PartitionsWithColumnStoreIndexesCursor
FETCH NEXT FROM @PartitionsWithColumnStoreIndexesCursor INTO @partitionNumber, @columnStoreIndexName, @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN

	--Getting fragmentation data
    EXEC [AnalyticsInternal].[prc_SelectColumnStoreIndexStats] @physicalPartitionId = @partitionNumber, @columnStoreIndexName = @columnStoreIndexName, @action = 'Collecting fragmentation data'

    FETCH NEXT FROM @partitionsWithColumnStoreIndexesCursor INTO @partitionNumber, @columnStoreIndexName, @tableName;
END

CLOSE @PartitionsWithColumnStoreIndexesCursor
DEALLOCATE @PartitionsWithColumnStoreIndexesCursor
