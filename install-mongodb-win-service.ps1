Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Set this to your MongoDB installation path
$installPath = "C:\MongoDB"

# Ensure that MongoDB is already installed
if ((Test-Path -path $installPath) -eq $False)
{
    write-host "Please install MongoDB to the following location: $installPath"
	exit
}

# Create directories
md "$installPath\log"
md "$installPath\data"
md "$installPath\data\db"

# Server configuration
$configFileContents = @"
dbpath={0}\data\db
logpath={0}\log\mongo.log
smallfiles=true
noprealloc=true
"@
$configPath = "$installPath\mongod.conf"
$stream = [System.IO.StreamWriter] $configPath
$stream.Write($configFileContents, $installPath)
$stream.close()

# Install as a Windows service
& $installPath\bin\mongod.exe --config $configPath --install

# Start the service
& net start mongodb

# Modify system environment variable
if ($env:Path -like "*MongoDB") {
    write-host "$installPath is already added to your system's environment variables"
	exit 
}
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $dbPath + "\bin", "Machine")