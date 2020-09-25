DECLARE @PartitionsWithColumnStoreIndexes TABLE (partition_number int, ColumnStoreIndexName nvarchar(256), TableName nvarchar(256), IsActive BIT)
INSERT INTO @PartitionsWithColumnStoreIndexes
EXEC [AnalyticsInternal].[prc_GetPartitionsWithColumnStoreIndexes]


DECLARE @PartitionsWithColumnStoreIndexesCursor CURSOR
DECLARE @partitionNumber NVARCHAR(256)
DECLARE @columnStoreIndexName NVARCHAR(256)
DECLARE @tableName NVARCHAR(256)
DECLARE @OverlapsData TABLE (DBName nvarchar(256), partition_number int, partitionId int, Overlaps int, SegmentsInPartition bigint, TableName nvarchar(256))

SET @PartitionsWithColumnStoreIndexesCursor = CURSOR LOCAL FORWARD_ONLY STATIC FOR
(
    SELECT partition_number, ColumnStoreIndexName, TableName FROM @PartitionsWithColumnStoreIndexes
)

OPEN @PartitionsWithColumnStoreIndexesCursor
FETCH NEXT FROM @PartitionsWithColumnStoreIndexesCursor INTO @partitionNumber, @columnStoreIndexName, @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @columnName NVARCHAR(256);

	SET @columnName = CASE 
	WHEN @tableName like '%WorkItem%'  THEN 'WorkItemRevisionSK'
	WHEN @tableName = 'AnalyticsModel.tbl_Test'  THEN 'TestSK'
	WHEN @tableName = 'AnalyticsModel.tbl_TestRun'  THEN 'TestRunSK'
	WHEN @tableName = 'AnalyticsModel.tbl_TestResult'  THEN 'TestResultSK'
	ELSE 'TestResultDailySK'
	END

	--Getting overlaps data
	INSERT INTO @OverlapsData
    EXEC [AnalyticsInternal].[prc_GetOverlapPerSegmentsInPartition] @partitionNumber = @partitionNumber, @tableName = @tableName, @columnName = @columnName
	
    FETCH NEXT FROM @partitionsWithColumnStoreIndexesCursor INTO @partitionNumber, @columnStoreIndexName, @tableName;
END

CLOSE @PartitionsWithColumnStoreIndexesCursor
DEALLOCATE @PartitionsWithColumnStoreIndexesCursor

select * from @OverlapsData
