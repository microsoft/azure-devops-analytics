Param(
  [Parameter(Mandatory=$False)]
  [string]
  $OutputPath = '.\'
)

$eventQueryFiles = Get-ChildItem '.\EventQueries' -Filter *.xml
$executionTimestamp = Get-Date -Format "yyyyMMdd_hhmmss"
$outputDirectory = Join-Path $OutputPath "AnalyticsEvents_$executionTimestamp"

If(!(Test-Path $outputDirectory))
{
      New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$outputDirectory = Convert-Path $outputDirectory
Write-Host "Output directory: " $outputDirectory

ForEach($eventQueryFile in $eventQueryFiles)
{
    Write-Host "Collecting events based on " $eventQueryFile.FullName 

    $outputFilePath = Join-Path -Path $outputDirectory -ChildPath "result_$($eventQueryFile.BaseName).evtx"
    $args = @('epl', $eventQueryFile.FullName, '/sq', $outputFilePath)
    & "C:\Windows\System32\wevtutil.exe" $args
    
    Write-Host "Output saved to $outputFilePath"
}

Add-Type -Assembly System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
[System.IO.Compression.ZipFile]::CreateFromDirectory($outputDirectory, "$outputDirectory.zip", $compressionLevel, $false)