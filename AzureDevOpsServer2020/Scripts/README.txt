DESCRIPTION: 
This collection of scripts will collect high-level information about your
Azure DevOps Server deployent to better understand how the Analytics service 
is operating and its effect on the system as a whole.

INSTRUCTIONS:

Run 'Export-AnalyticsMetrics.ps1' via PowerShell. (Preferred to run as Administrator)
       
  There are three parameters which can be specified:
    SqlServer          : Name of the SQL server. If omitted, assumed to be local server: '.'
    CollectionDatabase : Name of the collection database. If omitted, assumed to be default collection name: 'Tfs_DefaultCollection'
    OutputPath         : Relative or absolute path where the output should be saved. If ommited, assumed to be same folder as this script.

  Examples:
    Export-AnalyticsMetrics.ps1 -SqlServer . -CollectionDatabase Tfs_DefaultCollection 

    Export-AnalyticsMetrics.ps1 -SqlServer localhost -CollectionDatabase Tfs_Collection2 -OutputPath C:\MyFolder



If successful, a folder and a zip file named 'AnalyticsMetrics_[DATE_TIME]' will have been created.