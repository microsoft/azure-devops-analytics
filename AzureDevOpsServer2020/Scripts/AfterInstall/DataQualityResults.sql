SELECT  PartitionId,
FORMAT(RunDate, 'MM/dd/yyyy HH:mm:ss') AS RunDate,
FORMAT(StartDate, 'MM/dd/yyyy HH:mm:ss') AS StartDate,
FORMAT(EndDate, 'MM/dd/yyyy HH:mm:ss') AS EndDate,
Name,
TargetTable,
ExpectedValue,
ActualValue,
Failed,
KpiValue,
FORMAT(RunEndDate, 'MM/dd/yyyy HH:mm:ss') AS RunEndDate,
Scope
FROM    AnalyticsInternal.tbl_DataQualityResult