SELECT OBJECT_SCHEMA_NAME(object_id) as AxSchema, OBJECT_NAME(object_id) as AxObject,*
FROM sys.query_store_plan AS Pl
INNER JOIN sys.query_store_query AS Qry
	ON Pl.query_id = Qry.query_id
INNER JOIN sys.query_store_query_text AS Txt
	ON Qry.query_text_id = Txt.query_text_id 
WHERE OBJECT_SCHEMA_NAME(object_id) like 'Analytics%'