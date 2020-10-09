SELECT *
FROM AnalyticsInternal.tbl_Batch
WHERE (Failed = 1 OR FailedMessage IS NOT NULL)
ORDER BY CreateDateTime DESC