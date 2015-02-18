Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Configuration
$installPath = "C:\MongoDB"
$serverNamePrefix = "sc"
$hostName = "localhost"
$replicaSetId = "rs1"

# Ensure that MongoDB is already installed
if ((Test-Path -path $installPath) -eq $False)
{
    write-host "Please install MongoDB to the following location: $installPath"
	exit
}

# Define servers
$servers = @( 
     @{ "ServerName" = $serverNamePrefix + "01"; "Port" = 27017; "HostName" = $hostName; "Priority" = 100; "ReplicaSet" = $replicaSetId };
     @{ "ServerName" = $serverNamePrefix + "02"; "Port" = 27018; "HostName" = $hostName; "Priority" = 90; "ReplicaSet" = $replicaSetId };
     @{ "ServerName" = $serverNamePrefix + "03"; "Port" = 27019; "HostName" = $hostName; "Priority" = 80; "ReplicaSet" = $replicaSetId };
     # Define additional members here...
)

# Server configuration
$configFileContents = @"
dbpath={0}\data\db
logpath={0}\log\mongo.log
smallfiles=true
noprealloc=true
port = {1}
replSet = {2}
rest = true
"@

foreach($server in $servers)
{
    $serverName = $server["ServerName"]
    $serverPath = $installPath + "\" + $serverName
    $dataPath = "{0}\data\db" -f $serverPath
    $logPath = "{0}\log\" -f $serverPath

    # Create directories
    md $dataPath -ErrorAction SilentlyContinue
    md $logPath -ErrorAction SilentlyContinue

    # Create configuration
    $configPath = "{0}\{1}.conf" -f $serverPath, $serverName
    $stream = [System.IO.StreamWriter] $configPath
    $stream.Write($configFileContents, $serverPath, $server["Port"], $server["ReplicaSet"])
    $stream.close()

    # Install as service
    & $installPath\bin\mongod.exe --config $configPath --install --httpinterface --serviceName $serverName --serviceDisplayName $serverName

    # Start the service
    Start-Service -Name $serverName
}

# Replica set configuration
$rsConfig = @{
    "_id" = $replicaSetId;
    "version" = 1;
    "members" = New-Object System.Collections.ArrayList; 
}

$memberId = 0
foreach($server in $servers)
{
    $rsConfig["members"].Add( @{ "_id" = $memberId; "host" = $server["HostName"]+":"+$server["Port"]; "priority" = $server["Priority"]; } )
    $memberId += 1
}

$rsConfigJson = $rsConfig | ConvertTo-Json
$rsCommand = @"
rsConfig = $rsConfigJson
rs.initiate(rsConfig)
"@

$rsCommand | & $installPath\bin\mongo.exe --port 27017

# Modify system environment variable
if ($env:Path -like "*MongoDB") {
    write-host "$installPath is already added to your system's environment variables"
	exit 
}
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $installPath + "\bin", "Machine")