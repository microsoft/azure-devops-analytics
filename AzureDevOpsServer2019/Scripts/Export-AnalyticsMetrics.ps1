Param(
  [Parameter(Mandatory=$False)]
  [string]
  $SqlServer = '.',

  [Parameter(Mandatory=$False)]
  [string]
  $CollectionDatabase = 'AzureDevOps_DefaultCollection',

  [Parameter(Mandatory=$False)]
  [string]
  $ConfigDatabase = 'AzureDevOps_Configuration',

  [Parameter(Mandatory=$False)]
  [string]
  $OutputPath = '.\'
)

#===========================================================================================
$sqlQueryFiles = Get-ChildItem '.\AfterInstall' -Filter *.sql
$executionTimestamp = Get-Date -Format "yyyyMMdd_hhmmss"
$outputDirectory = Join-Path $OutputPath "AnalyticsMetrics_$executionTimestamp"

If(!(Test-Path $outputDirectory))
{
      New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$outputDirectory = Convert-Path $outputDirectory
Write-Host "Output directory: " $outputDirectory

# Query metrics
ForEach($sqlQueryFile in $sqlQueryFiles)
{
    Write-Host "Loading SQL query from " $sqlQueryFile.FullName 
    $queryText = Get-Content -Path $sqlQueryFile.FullName | Out-String

    $outputFilePath = Join-Path -Path $outputDirectory -ChildPath "result_$($sqlQueryFile.BaseName).csv"
    Invoke-Sqlcmd -ServerInstance $SqlServer -Database $CollectionDatabase -Query $queryText | Export-CSV $outputFilePath
    
    Write-Host "Output saved to $outputFilePath"
}
#===========================================================================================
# Config DBs query
$sqlQueryFiles = Get-ChildItem '.\Config' -Filter *.sql

Write-Host "Output directory: " $outputDirectory

# Query Config DB
ForEach($sqlQueryFile in $sqlQueryFiles)
{
    Write-Host "Loading SQL query from " $sqlQueryFile.FullName 
    $queryText = Get-Content -Path $sqlQueryFile.FullName | Out-String

    $outputFilePath = Join-Path -Path $outputDirectory -ChildPath "result_$($sqlQueryFile.BaseName).csv"
    Invoke-Sqlcmd -ServerInstance $SqlServer -Database $ConfigDatabase -Query $queryText | Export-CSV $outputFilePath
    
    Write-Host "Output saved to $outputFilePath"
}
#===========================================================================================
$exportSchemaFile = (Get-ChildItem '.\Schema\' -Filter SchemaQuery.sql)[0]
# Export Analytics schema metadata tables
ForEach($table in Get-Content .\axtables.txt)
{
    Write-Host "Loading SQL query from " $exportSchemaFile.FullName 
    Write-Host "Exporting table schema for" $table
    $queryText = Get-Content -Path $exportSchemaFile.FullName | Out-String

    $tableNameParam = @("TABLENAME=" + $table)

    $outputFilePath = Join-Path -Path $outputDirectory -ChildPath "schema_$($table).csv"
    Invoke-Sqlcmd -ServerInstance $SqlServer  -MaxCharLength 8000 -Database $CollectionDatabase -Query $queryText -Variable $tableNameParam |  Export-CSV $outputFilePath

    Write-Host "Output saved to $outputFilePath"
}
#===========================================================================================
# Export Analytics metadata tables
ForEach($table in Get-Content .\axtables.txt)
{
    Write-Host "Exporting table " $table
    bcp "$($CollectionDatabase).$($table)" out "$($outputDirectory)\$($table).csv" -c -T -E -k
    bcp "$($CollectionDatabase).$($table)" format  nul -f "$($outputDirectory)\$($table).fmt" -c -T -E -x
}
#===========================================================================================
# Export config metadata tables
ForEach($table in Get-Content .\configtables.txt)
{
    Write-Host "Exporting table " $table
    bcp "$($ConfigDatabase).$($table)" out "$($outputDirectory)\$($table).csv" -c -T -E -k
    bcp "$($ConfigDatabase).$($table)" format  nul -f "$($outputDirectory)\$($table).fmt" -c -T -E -x
}

Add-Type -Assembly System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
[System.IO.Compression.ZipFile]::CreateFromDirectory($outputDirectory, "$outputDirectory.zip", $compressionLevel, $false)