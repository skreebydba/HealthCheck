function Invoke-HealthCheck {
<#
.SYNOPSIS
Automates the execution of health assessment scripts

.DESCRIPTION
Executes T-SQL scripts from a file path, writes the result sets to script-specific .csv files.
If Excel is running on the source server, the .csv files are combined into an Excel spreadsheet.

.EXAMPLE
Invoke-Healthcheck -Version 2016 -Instance localhost -Client Concurrency -FilePath "C:\HealthCheck";

.PARAMETER Version
The version of SQL Server you are running against [2005-2016]

.PARAMETER Instance
The SQL Server instance you are running against

.PARAMETER Client
The client you are running the health check for

.PARAMETER FilePath
The file path that contains your T-SQL scripts
The .csv and .xlsx files will be written to this path

#>
[CmdletBinding()]
param
(

[Parameter(Mandatory=$True,
Position = 1,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True,
    HelpMessage='What instance of SQL Server are you running against?  If default, enter the server name.')]
[Alias('instancename')]
[string]$instance,

[Parameter(Mandatory=$True,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True,
    HelpMessage='What client are you running the health check for?')]
[Alias('clientname')]
[string]$client,

[Parameter(Mandatory=$True,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True,
    HelpMessage='What is the file path containing your health check scripts?')]
[Alias('scriptpath')]
[string]$filepath

)

process {
        
    <#
    The code to combine the .csv files into an .xlsx file was taken from the following link:
    https://realgsuseethernet.wordpress.com/2012/08/23/powershell-script-to-combine-multiple-csv-files-into-an-xlsx-file-2/
    #>

    cls;

    $sqlpath = "$filepath\*.sql";
    $outputpath = "$filepath\output";
    $removepath = "$outputpath\*"
    $indexpath = "$filepath\IndexQueries"
    $fileexists = Test-Path $outputpath;

    if($fileexists -eq $false)
    {
        New-Item $outputpath -Type Directory;
    }
    else
    {
        Remove-Item $removepath -Include *.csv, *.xlsx;
    }

    Invoke-Sqlcmd -ServerInstance $instance -InputFile 'C:\HealthCheckInsert\CreateDbAndTables\CreateHealthCheckTables.sql';

    $databases = Invoke-Sqlcmd -ServerInstance $instance -Query "USE master;  SELECT name FROM sys.databases WHERE database_id > 4;";
    $databasenames = $databases.name;

    $sqlfiles = Get-ChildItem $sqlpath -Include *.sql | Select Name;
    $indexfiles = Get-ChildItem "$indexpath\*" -Include *.sql | Select Name;

    #Remove-Item $removepath -Include *.csv, *.xlsx;

    foreach($sqlfile in $sqlfiles)
    {
    
        $query = $filepath + "\" + $sqlfile.name;
        $csvfile = $sqlfile.Name -replace ".sql", ".csv"
        $csvpath = $outputpath + "\" + $csvfile;
        $query;
        Invoke-Sqlcmd -InputFile $query | Export-Csv -Path $csvpath -NoTypeInformation;

    }

    Set-Location $indexpath;

    ForEach ($databasename in $databasenames)
    {
        
        $validpath = Test-Path $databasename;

        if($validpath -eq $true)
        {
            Remove-Item -Path $databasename -Recurse;
        }

        New-Item -Path $databasename -ItemType "directory" | Out-Null;

        ForEach ($indexfile in $indexfiles)
        {
            
            $csvfilename = $indexfile.name -replace ".sql", ".csv";
            $csvfilename = $databasename + "_" + $csvfilename;
            $csvpath = "$indexpath\$databasename\$csvfilename";
            
            Invoke-Sqlcmd -ServerInstance localhost -Database $databasename -InputFile $indexfile.name | Export-Csv -Path $csvpath -NoTypeInformation;
    #           $sqlfilename;
        }
    }
}
}

