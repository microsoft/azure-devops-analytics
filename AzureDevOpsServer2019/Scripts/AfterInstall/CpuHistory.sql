-- Collect 256 minutes (~4 hours) of SQL CPU usage.
-- Note: This will not work in Azure SQL.

DECLARE @ts BIGINT;
SELECT  @ts = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info); 

WITH XmlData AS
(
    SELECT  [timestamp], CONVERT(xml, record) AS [record]
    FROM    sys.dm_os_ring_buffers
    WHERE   ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR ' AND record LIKE '%%'
),

CpuData AS
(
    SELECT  record.value('(./Record/@id)[1]','int') AS record_id,
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int') AS [SystemIdle],
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int') AS [SQLProcessUtilization],
            [timestamp]
    FROM    XmlData
)

SELECT  FORMAT(DATEADD(ms, -1 * (@ts - [timestamp]), GETDATE()), 'MM/dd/yyyy HH:mm:ss') AS [Event_Time],
        SQLProcessUtilization AS [SQLServer_CPU_Utilization],
        SystemIdle AS [System_Idle_Process],
        100 - SystemIdle - SQLProcessUtilization AS [Other_Process_CPU_Utilization]
FROM    CpuData
ORDER BY record_id DESC