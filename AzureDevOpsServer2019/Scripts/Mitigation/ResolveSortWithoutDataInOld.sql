DECLARE @startPartitionId INT,
		@endPartitionId INT,
		@partitionNumber INT,
		@tableName NVARCHAR(256),
		@shortTableName NVARCHAR(256),
		@partitionSchemaMainTableName NVARCHAR(256),
		@partitionFunctionMainTableName NVARCHAR(256),
		@transformTableNameHeld NVARCHAR(256)

DECLARE @tableValues TABLE (TableName NVARCHAR(256), TableMaintenanceId INT)

SELECT	--*,
		TOP(1)
		@startPartitionId = StartPartitionId, 
		@endPartitionId = EndPartitionId, 
		@shortTableName = TableName,
		@tableName = 'AnalyticsModel.' + TableName
FROM AnalyticsInternal.tbl_TableMaintenance
WHERE Operation = 'SORT'
AND IsActive = 1

SELECT	--*,
		@partitionSchemaMainTableName = PartitionScheme, 
		@transformTableNameHeld = TransformTableName
FROM [AnalyticsInternal].[func_iGetTableMaintenanceDefinitions] () 
WHERE TableName = @tableName

select TOP (1) @partitionFunctionMainTableName = pf.name, @partitionSchemaMainTableName = ps.Name 
    from sys.indexes i  
    join sys.partition_schemes ps on ps.data_space_id = i.data_space_id  
    join sys.partition_functions pf on pf.function_id = ps.function_id  
where i.object_id = object_id(@tableName)

IF (    
		@startPartitionId IS NOT NULL
		AND @endPartitionId IS NOT NULL 
		AND @shortTableName IS NOT NULL 
		AND @tableName IS NOT NULL 
		AND @partitionSchemaMainTableName IS NOT NULL 
		AND @partitionFunctionMainTableName IS NOT NULL 
		AND @transformTableNameHeld IS NOT NULL 
)
BEGIN

	SELECT	@startPartitionId AS StartPartitionId, 
			@endPartitionId AS EndPartitionId, 
			@shortTableName AS ShortTableName,
			@tableName AS TableName,
			@partitionSchemaMainTableName AS PartitionScheme,
			@partitionFunctionMainTableName AS PartitionFunction,
			@transformTableNameHeld AS TransformTableName

	DECLARE @cmd NVARCHAR(MAX) = N'
IF NOT EXISTS (SELECT * FROM sys.partitions (NOLOCK) WHERE object_id = OBJECT_ID('+ @tableName + '_Old) AND rows > 0)
BEGIN    
    EXEC prc_DisableRls @SchemaName=''AnalyticsModel'', @tableName=''' + @tableName + '_Old''
    EXEC prc_DisableRls @SchemaName=''AnalyticsModel'', @tableName= ''' + @tableName + '_Temp''

    DROP TABLE IF EXISTS ' + @tableName + '_Temp
    DROP TABLE IF EXISTS ' + @tableName + '_Old

    DROP PARTITION SCHEME ' + @partitionSchemaMainTableName + '_Merge
    DROP PARTITION SCHEME ' + @partitionSchemaMainTableName + '_Split

    DROP PARTITION FUNCTION ' + @partitionFunctionMainTableName + '_Merge
    DROP PARTITION FUNCTION ' + @partitionFunctionMainTableName + '_Split

    UPDATE AnalyticsInternal.tbl_TableMaintenance
    SET IsActive = 0
    WHERE IsActive = 1 AND TableName= '''+ @shortTableName +''' AND StartPartitionId = ' + CAST(@startPartitionId AS NVARCHAR(20))+' AND EndPartitionId = ' + CAST(@endPartitionId AS NVARCHAR(20)) + '

	EXEC AnalyticsInternal.prc_SetTransformHold @hold = 0, @reason=''Cancelling sort'', @targetTableName = ''' + @transformTableNameHeld + ''', @firstPartitionId =' + CAST(@startPartitionId AS NVARCHAR(20)) + ', @lastPartitionId = ' + CAST(@endPartitionId AS NVARCHAR(20)) + ' 

END
'
	SELECT @cmd
	EXEC sp_Executesql @cmd
END