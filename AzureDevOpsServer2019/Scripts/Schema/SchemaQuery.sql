DECLARE @tableName NVARCHAR(255) = '$(TABLENAME)'
DECLARE @status INT
DECLARE @tfError NVARCHAR(255)
DECLARE @errorMessage NVARCHAR(255)
DECLARE @procedureName SYSNAME =  @@SERVERNAME + '.' + DB_NAME() + '.' + OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

DECLARE @newLine CHAR(2) = CHAR(13)+CHAR(10)
    
DECLARE @cmd NVARCHAR(MAX) ='CREATE TABLE '+@tableName + @newLine +'('

SELECT 
@cmd += @newLine
    +CHAR(9)
    + c.name 
    + ' '
    + t.name -- Keeping original name, using UPPER causes issues for turkish locale
    + CASE t.name
        WHEN 'varchar' THEN CONCAT('(', c.max_length, ')')
        WHEN 'nvarchar' THEN CONCAT('(', c.max_length/2, ')')
        WHEN 'datetimeoffset' THEN CONCAT('(', c.scale, ')')
        WHEN 'decimal' THEN CONCAT('(', c.precision,',', c.scale, ')')
        ELSE '' END
    + ' '
    + IIF (c.is_nullable = 0, 'NOT NULL', 'NULL')
    + IIF (c.is_identity = 1, ' IDENTITY', '')
    + ','
FROM sys.columns c
JOIN sys.types t 
ON c.system_type_id=t.system_type_id 
AND c.user_type_id=t.user_type_id
WHERE c.object_id=OBJECT_ID(@tableName)
ORDER BY column_id
    
SELECT @cmd = SUBSTRING(@cmd, 1, LEN(@cmd) - 1) + @newLine +')'

SELECT Query = @cmd
    
