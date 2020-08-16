<!-- Chapter Start -->

# Get Database Info
This code returns information about databases on an instance of SQL Server.

```ps

$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach($instance in $instances)
{
    Get-DbaDatabase -SqlInstance $instance | Select-Object -Property SqlInstance, Name, ID, SizeMB, DataSpaceUsage, IndexSpaceUsage, CreateDate,Compatibility, LogReuseWaitStatus, Owner, PageVerify, RecoveryModel, DatabaseEngineEdition, LastFullBackup, LastDiffBackup, LastLogBackup, AutoClose, AutoShrink, Collation,  DefaultFileGroup, DefaultSchema, HasMemoryOptimizedObjects, IsReadCommittedSnapshotOn;
}
```
<!-- Chapter End -->
<!-- Chapter Start -->

# Get VLF Info
This code returns VLF counts for each database on an instance.

```ps

#$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach($instance in $instances)
{
    $vlfs = Get-DbaDbVirtualLogFile -SqlInstance $instance;
    $vlfs | Group-Object -Property Database | Select-Object -Property Count, Name;
}
```
<!-- Chapter End -->
<!-- Chapter Start -->

# Get VLF Info Grouped By Status Test
This code return VLF counts for each database on an instance grouped by VLF status.

```ps

#$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach($instance in $instances)
{
    $vlfs = Get-DbaDbVirtualLogFile -SqlInstance $instance;
    $groups = $vlfs | Group-Object -Property Database, Status | Select-Object -Property Count, Name; 

    foreach($group in $groups)
    {
        
        $name = $group.Name;
        $count = $group.Count;
        $parsed = ConvertFrom-String $name -Delimiter "," -PropertyNames DatabaseName, VlfStatus;
        $vlfstatus = New-Object -TypeName psobject;
        $vlfstatus | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $parsed.DatabaseName;
        $vlfstatus | Add-Member -MemberType NoteProperty -Name VlfStatus -Value $parsed.VlfStatus;
        $vlfstatus | Add-Member -MemberType NoteProperty -Name VlfCount -Value $count;
        $vlfstatus | Select-Object -Property DatabaseName, VlfStatus, VlfCount;
    }
}
```
<!-- Chapter End -->
<!-- Chapter Start -->

# Get Data File Information
This code returns detailed information about data files on an instance of SQL Server.

```ps

#$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach($instance in $instances)
{
    Get-DbaDbFile -SqlInstance $instance | Select-Object -Property SqlInstance, Database, FileGroupName, TypeDescription, LogicalName, PhysicalName, MaxSize, Growth, GrowthType, Size, UsedSpace, AvailableSpace, NumberOfDiskWrites, NumberOfDiskReads, ReadFromDisk, WritesToDisk | Where TypeDescription -eq "Rows";
}

```

<!-- Chapter End -->

<!-- Chapter Start -->

# Get Log File Information
This code returns detailed information about transaction log files on an instance of SQL Server.

```ps

#$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach($instance in $instances)
{
    Get-DbaDbFile -SqlInstance $instance | Select-Object -Property SqlInstance, Database, FileGroupName, TypeDescription, LogicalName, PhysicalName, MaxSize, Growth, GrowthType, Size, UsedSpace, AvailableSpace, NumberOfDiskWrites, NumberOfDiskReads, ReadFromDisk, WritesToDisk | Where TypeDescription -eq "Log";
}

```

<!-- Chapter End -->
<!-- Chapter Start -->
# Get sys.configuration Settings
This code returns the value and value_in_use from the sys.configuration table for an instance of SQL Server.  

```ps
$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach ($instance in $instances)
{
    $configs = Get-DbaSpConfigure -SqlInstance $instance | Select-Object -Property Name, ConfiguredValue, RunningValue | Sort-Object -Property Name;
    foreach($config in $configs)
    {
        $configout = New-Object -TypeName psobject;
        $configout | Add-Member -MemberType NoteProperty -Name SqlInstance -Value $instance;
        $configout | Add-Member -MemberType NoteProperty -Name Configuration -Value $config.Name;
        $configout | Add-Member -MemberType NoteProperty -Name Value -Value $config.ConfiguredValue;
        $configout | Add-Member -MemberType NoteProperty -Name ValueInUse -Value $config.RunningValue;
        $configout;
    }
}
```
<!-- Chapter End -->

<!-- Chapter Start -->
# Get SQL Agent Alerts
This code return all existing SQL Agent alerts for a SQL Server instance.

```ps
$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach ($instance in $instances)
{
    $alerts = Get-DbaAgentAlert -SqlInstance $instance;
    foreach($alert in $alerts)
    {
        $instancealert = New-Object -TypeName psobject;
        $instancealert | Add-Member -MemberType NoteProperty -Name SqlInstance -Value $instance;
        $instancealert | Add-Member -MemberType NoteProperty -Name AlertName -Value $alert;
        $instancealert;
    }
}
```
<!-- Chapter End -->

<!-- Chapter Start -->
# Get Wait Stats
This code returns wait stats for a SQL Server instance sorted by percentage descending.

```ps

$instances = Get-Content -Path C:\Users\fgill\Documents\GitHub\AzureDataStudioAndContainers\instances.txt;

foreach ($instance in $instances)
{
    $waitstats = Get-DbaWaitStatistic -SqlInstance $instance;
    foreach($waitstat in $waitstats)
    {
         $instancewait = New-Object -TypeName psobject;
         $instancewait | Add-Member -MemberType NoteProperty -Name SqlInstance -Value $instance;
         $instancewait | Add-Member -MemberType NoteProperty -Name Category -Value $waitstat.Category;
         $instancewait | Add-Member -MemberType NoteProperty -Name WaitType -Value $waitstat.WaitType;
         $instancewait | Add-Member -MemberType NoteProperty -Name Percentage -Value $waitstat.Percentage;
         $instancewait | Add-Member -MemberType NoteProperty -Name WaitCount -Value $waitstat.WaitCount;
         $instancewait | Add-Member -MemberType NoteProperty -Name WaitSeconds -Value $waitstat.WaitSeconds;
         $instancewait | Add-Member -MemberType NoteProperty -Name ResourceSeconds -Value $waitstat.ResourceSeconds;
         $instancewait | Add-Member -MemberType NoteProperty -Name SignalSeconds -Value $waitstat.SignalSeconds;
         $instancewait | Add-Member -MemberType NoteProperty -Name AvgWaitSeconds -Value $waitstat.AverageWaitSeconds;
         $instancewait | Add-Member -MemberType NoteProperty -Name AvgResourceSeconds -Value $waitstat.AverageResourceSeconds;
         $instancewait | Add-Member -MemberType NoteProperty -Name AvgSignalSeconds -Value $waitstat.AverageSignalSeconds;

         $instancewait | Sort-Object -Property Percentage -Descending;

    }
}
```
<!-- Chapter End -->
<!-- Chapter Start -->

# Rename Worksheets and Zip Spreadsheet

```ps

$rundate = Get-Date -Format yyyyMMdd_HHmmss;
$workbook = ".\healthcheck.xlsx";
$newworkbook = ".\healthcheck_$rundate.xlsx";
$worksheets = "Sheet1", "Sheet2", "Sheet3", "Sheet4","Sheet5", "Sheet6", "Sheet7", "Sheet8";

$newworksheets = "DatabaseInfo", "VLFInfo", "VlfByStatus", "DateFileInfo", "LogFileInfo", "Configuration", "AgentAlerts", "WaitStats";
$newindex = 0;

foreach($worksheet in $worksheets)
{
    Import-Excel -Path $workbook -WorksheetName $worksheet | Export-Excel -Path $newworkbook -WorksheetName $newworksheets[$newindex];
    $newindex += 1;
}

$archive = $newworkbook.Replace("xlsx","zip");

$compress = @{
  Path = $newworkbook
  CompressionLevel = "Fastest"
  DestinationPath = $archive;
}
Compress-Archive @compress;

<!-- Remove-Item -Path $workbook;
Remove-Item -Path $newworkbook; -->

```

<!-- Chapter End -->