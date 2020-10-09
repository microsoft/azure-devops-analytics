SELECT *
FROM AnalyticsInternal.tbl_Batch
WHERE CreateDateTime >= DATEADD(HOUR, -6, GETUTCDATE())
ORDER BY OperationDurationMS DESC