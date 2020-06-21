# PoShLumberjack

[![Build status](https://ci.appveyor.com/api/projects/status/4loxtsfmwvae8cqc/branch/master?svg=true)](https://ci.appveyor.com/project/EmmanuelPineiro/poshlumberjack/branch/master)

## Install PoShLumberjack
```powershell
PS> Install-Module PoShLumberjack
```

## Setup PoShLumberjack

### Create a log file with no args
No arguments are needed to create a log file. This will:
  - use a default dir
  - default dateTime format
  - not show Log-Debug
  - create a new log file with timestamp in the name

Defaults:
  - LogPath: "$env:TEMP\PoShLumberjack\log\Lumberjack.log"
  - DateFormat: "yyyyMMddHHmmss"

```powershell
Start-Logger
```

### Create a new time stamped log each time
```powershell
# Specify where your logs are created, and how the date time gets added before the extension
$LogPath = 'C:\logs\lumberjack.log'
$DateFormat = 'yyyyMMdd-HH:mm:ss'
Start-Logger -LogPath $LogPath -LogNote $LogNote -DateFormat $DateFormat

# Default colors are INFO='White'; WARN='Yellow'; ERROR='Red'; DEBUG='Cyan'. They can be changed using the Set-LevelTextColor command. 
Set-LevelTextColor "INFO" "DarkMagenta"
```

### Create a new log file with no time stamp
```powershell
# If you don't want the log file name to be modified with the date, use the -NoDateTime switch
Start-Logger -NoDateTime
```

### Create a log file and include Log-Debug calls
```powershell
# By default, debug logging will not write to host or file. Pass the -IsDebug switch to get Log-Debug entries to show
Start-Logger -IsDebug
```

## Using PoShLumberjack
```powershell
# Logging will write to file and write-host in color
Log-Info "an info message"
Log-Debug "a debug message"
Log-Warn "a warn message"
Log-Error "an error message"
```