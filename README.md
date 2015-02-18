# Install MongoDB as a Windows Service

### Steps
1. Install MongoDB from http://www.mongodb.org/downloads
2. Make note of the installation path
3. Update the script with the installation path
4. Run the PowerShell script as Administrator

To reverse what this script does, run: 
> net stop MongoDB
> sc delete MongoDB
> rmdir C:\InstallPath\data
> rmdir C:\InstallPath\log
> del C:\InstallPath\mongod.conf

Also, remember to clear out the MongoDB install path from your Environment Variables.

A more advanced script that is capable of creating replica sets is available at:
https://github.com/Sitecore/psmongoserviceinstall

