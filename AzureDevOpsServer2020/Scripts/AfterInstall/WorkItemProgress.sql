-- Collect data about database size, row counts, and Analytics initialization progress.

DECLARE @tbl_results TABLE (results NVARCHAR(MAX))

DECLARE @witCount INT = (SELECT COUNT(*) FROM [dbo].[tbl_WorkItemCoreLatest] WHERE PartitionId > 0)
DECLARE @wirCount INT, @wirMax INT, @wirAverage FLOAT, @wirDev FLOAT

SELECT @wirCount = SUM(Rev), @wirMax = MAX(Rev), @wirAverage = AVG(Rev), @wirDev = STDEVP(Rev)
FROM [dbo].[tbl_WorkItemCoreLatest]
WHERE PartitionId > 0

DECLARE @witSizeKB INT = (
        SELECT  SUM(ps.reserved_page_count) / 128
        FROM    sys.tables t
        JOIN    sys.indexes i
        ON      t.object_id = i.object_id
        JOIN    sys.schemas s
        ON      t.schema_id = s.schema_id
        JOIN    sys.dm_db_partition_stats ps
        ON      ps.object_id = t.object_id
                AND ps.index_id = i.index_id
        WHERE   s.name NOT LIKE 'Analytics%'
        AND     t.name LIKE 'tbl_WorkItem%'
)

DECLARE @dbSizeKB INT = (SELECT SUM(size / 128) FROM sys.database_files WHERE type = 0)

INSERT INTO @tbl_results
VALUES  ('Operational store information:'),
        ('    Work items: ' + CAST(@witCount AS NVARCHAR(12))),
        ('    Work item revisions: ' + CAST(@wirCount AS NVARCHAR(12))),
		('    Max work item revisions: ' + CAST(@wirMax AS NVARCHAR(12))),
		('    Average work item revisions: ' + CAST(@wirAverage AS NVARCHAR(12))),
		('    Stdev work item revisions: ' + CAST(@wirDev AS NVARCHAR(12))),
        ('    WIT size: ' + CAST(CAST(@witSizeKB AS DECIMAL) / 1024 AS NVARCHAR(12)) + ' GB'),
        ('    DB size: ' + CAST(CAST(@dbSizeKB AS DECIMAL) / 1024 AS NVARCHAR(12)) + ' GB')

DECLARE @axWitCount INT = (SELECT COUNT(*) FROM AnalyticsModel.tbl_WorkItem)
DECLARE @axWirCount INT = (SELECT COUNT(*) FROM AnalyticsModel.tbl_WorkItemHistory)

IF @wirCount = @axWirCount + @axWitCount 
BEGIN
    DECLARE @axSizeKB INT = (
            SELECT  SUM(ps.reserved_page_count) / 128
            FROM    sys.tables t
            JOIN    sys.indexes i
            ON      t.object_id = i.object_id
            JOIN    sys.schemas s
            ON      t.schema_id = s.schema_id
            JOIN    sys.dm_db_partition_stats ps
            ON      ps.object_id = t.object_id
                    AND ps.index_id = i.index_id
            WHERE   s.name LIKE 'Analytics%'
    )

    DECLARE @startTime DATETIME = (
        SELECT  MIN(CreateTime) 
        FROM    AnalyticsInternal.tbl_TableProviderShardStream
        WHERE   PartitionId > 0
                AND TableName NOT IN ('Collection', 'Tag')
    )

    DECLARE @endTime DATETIME = (
        SELECT  MAX(ReadyDateTime)
        FROM    AnalyticsInternal.tbl_Batch
        WHERE   PartitionId > 0
                AND AnalyticsStreamId IS NULL
    )

    DECLARE @lastWIT DATETIME = (SELECT MAX(CreatedDate) FROM AnalyticsModel.tbl_WorkItem)

    INSERT INTO @tbl_results
    VALUES  ('AX WIT Initialization Complete:'),
            ('    AX size: ' + CAST(CAST(@axSizeKB AS DECIMAL) / 1024 AS NVARCHAR(12)) +' GB'),
            ('    Start: ' + FORMAT(@startTime, 'MM/dd/yyyy HH:mm:ss')),
            ('    End: ' + FORMAT(@endTime, 'MM/dd/yyyy HH:mm:ss')),
            ('    Last WIT created: ' + FORMAT(@lastWIT, 'MM/dd/yyyy HH:mm:ss'))
END
ELSE
BEGIN
    DECLARE @axWitCountLastHour INT = (
        SELECT  COUNT(*) 
        FROM    AnalyticsModel.tbl_WorkItem
        WHERE   AnalyticsCreatedDate > DATEADD(HOUR, -1, GETUTCDATE())
    )

    DECLARE @axWirCountLastHour INT = (
        SELECT  COUNT(*)
        FROM    AnalyticsModel.tbl_WorkItemHistory
        WHERE   AnalyticsCreatedDate > DATEADD(HOUR, -1, GETUTCDATE())
    )

    DECLARE @hoursRemaining DECIMAL(18,4) = ((@wirCount - @axWirCount - @axWitCount) / ISNULL(NULLIF(CAST(@axWitCountLastHour + @axWirCountLastHour AS DECIMAL), 0), 1))

    INSERT INTO @tbl_results
    VALUES  ('AX WIT initialization in progress:'),
            ('    ' + CAST(CAST(@axWirCount + @axWitCount AS DECIMAL) / @wirCount * 100 AS NVARCHAR(50)) + '% complete'),
            ('    Revisions processed in the last hour: ' + CAST(@axWitCountLastHour + @axWirCountLastHour AS NVARCHAR(12))),
            ('    Hours remaining: ' + CAST(@hoursRemaining AS NVARCHAR(50))),
            ('    Estimated completion: ' + FORMAT(DATEADD(HOUR, @hoursRemaining, GETUTCDATE()), 'MM/dd/yyyy HH:mm:ss') + ' UTC'),
            ('    Work remaining: ' + CAST(@wirCount - @axWirCount - @axWitCount AS NVARCHAR(50)))
END

SELECT * from @tbl_results