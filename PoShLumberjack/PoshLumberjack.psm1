$script:FilePath
$script:LevelColors = @{INFO='White'; WARN='Yellow'; ERROR='Red'; DEBUG='Cyan'}
$script:IsDebug = $false

#region accessor functions
<#
.DESCRIPTION
Set the text color write-host uses for a specific log level (i.e. INFO, WARN, ERROR, DEBUG)

.PARAMETER Level
The log level to set the color for
Valid options: "INFO", "WARN", "ERROR", "DEBUG"

.PARAMETER Color
The Color to use for the specified log level text
Valid options: "Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow",
  "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White"
.EXAMPLE
Set-LevelTextColor "INFO" "Green"
#>
function Set-LevelTextColor {
  param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
    [String]
    $Level,
    [Parameter(Mandatory=$true, Position=1)]
    [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
    [String]
    $Color
  )
  $script:LevelColors.$Level = $Color
  Write-Host "Set $Level to $Color"
}

<#
.DESCRIPTION
Gets the full log file path
.EXAMPLE
$logFilePath = Get-LogFilePath
#>
function Get-LogFilePath {
  if ($script:FilePath) {
    return $script:FilePath
  }
  else {
    Write-Host "Log file has not yet been created" -ForegroundColor Red
  }
}
#endregion

#region private functions
function Get-LinePrefix {
  param (
      [Parameter(Position=0)][datetime]$dateTime=(Get-Date),
      [Parameter(Position=1)][string]$Level="INFO"
  )

  return "[$($dateTime.ToString("yyyyMMddHHmmss"))][$tag]"
}

function Write-Log {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message,
    [Parameter(Position=1)][string]$tag="INFO"
  )

    $Message = "$(Get-LinePrefix -tag $tag) $Message"
    Add-Content -Path $script:FilePath -Value $Message
    Write-Host $Message -ForegroundColor $script:LevelColors.$tag
}

function Setup-Dir {
  param (
    [Parameter(Position=0)][string]$path="$env:TEMP\PoShLumberjack\"
  )
  $pathParts = $path.Split("\")
  $workingPath
  foreach ($part in $pathParts) {
    $workingPath += "$part\"
    if (-not (Test-Path $workingPath)) {
      $dir = New-Item -ItemType Directory -Path $workingPath
      Write-Verbose "  Created: $($dir.FullName)"
    }
  }
}

function Get-LogFileName {
  param (
    [Parameter(Position=0)][string]$FileName="Lumberjack.log",
    [Parameter(Position=1)][string]$DateFormat="yyyyMMddHHmmss"
  )

  $FileName = Split-Path $FileName -Leaf
  $Extension = $FileName.Split('.') | Select-Object -Last 1
  $BaseFileName = $FileName.Substring(0, $FileName.Length - $Extension.Length - 1)

  return "$BaseFileName-$(Get-Date -Format $DateFormat).$Extension"
}

function Create-LogFile {
  param (
    [Parameter(Position=0)][string]$LogFilePath="$env:TEMP\PoShLumberjack\PoShLumberjack.log",
    [Parameter(Position=1)][string]$DateFormat="yyyyMMddHHmmss",
    [Parameter(Position=2)][switch]$NoDateTime=$false
  )

  if (-not(Test-Path $LogFilePath)) {
    $path = Split-Path $LogFilePath -Parent
    $file = Split-Path $LogFilePath -Leaf

    Setup-Dir $path
    if (-not $NoDateTime) {
      $file = Get-LogFileName $file $DateFormat
    }
    $fullName = Join-Path $path $file
    $log = New-Item -ItemType File -Path $fullName
    return $log
  }
}

#endregion

#region public functions
<#
.DESCRIPTION
Writes INFO level message to log file and write-host

.PARAMETER Message
The message to log

.EXAMPLE
Log-Info "Something waranting info happened!"

.NOTES
Default write-host in WHITE. Can be set using Set-LevelTextColor
#>
function Log-Info {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  Write-Log $Message "INFO"
  # Write-Information $Message
}

<#
.DESCRIPTION
Writes WARN level message to log file and write-host

.PARAMETER Message
The message to log

.EXAMPLE
Log-Warn "Something waranting WARN happened!"

.NOTES
Default write-host in YELLOW. Can be set using Set-LevelTextColor
#>
function Log-Warn {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  Write-Log $Message "WARN"
  # Write-Warning $Message
}

<#
.DESCRIPTION
Writes ERROR level message to log file and write-host

.PARAMETER Message
The message to log

.EXAMPLE
Log-Error "Something waranting ERROR happened!"

.NOTES
Default write-host in RED. Can be set using Set-LevelTextColor
#>
function Log-Error {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  Write-Log $Message "ERROR"
  # Write-Error $Message
}

<#
.DESCRIPTION
Writes DEBUG level message to log file and write-host

.PARAMETER Message
The message to log

.EXAMPLE
Log-Debug "Something waranting DEBUG happened!"

.NOTES
Default write-host in CYAN. Can be set using Set-LevelTextColor
#>
function Log-Debug {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  if ($script:isDebug) {
    Write-Log $Message "DEBUG"
  }
  Write-Debug $Message
}

<#
.DESCRIPTION
Creates the log file. This includes creating any directories listed in the -LogPath that don't 
exist and creates the log file name. File name creation includes getting the datetime to add
before the file extension.

.PARAMETER LogPath
The full path of where the log file will exist. If "C:\log\lumberjack.log" is passed, then the 
"log" directory will be created. By default, the file name created in this example would result
in a file name "lumberjack-yyyyMMddHHmmss.log" where "yyyyMMddHHmmss" would be the datetime in 
that format.

Default: "$env:TEMP\PoShLumberjack\log\Lumberjack.log"

.PARAMETER LogNote
A normal log-Info entry with an added [NOTE] tag just in case you have something of note you 
want to add. Might be good if you keep a rolling log.

Will show up like this:
========================
[yyyyMMddHHmmss][INFO][NOTE] My important note about the thing this is doing
========================

.PARAMETER DateFormat
The format in which you want the date to appear in the file name

Default: "yyyyMMddHHmmss"
Example: "yyMMdd"
Doc: https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings

.PARAMETER IsDebug
By default, debug logging will not write to host or file. Pass the -IsDebug switch to get Log-Debug entries to show

.PARAMETER NoDateTime
If you don't want the log file name to be modified with the date, use the -NoDateTime switch

.EXAMPLE
Start-Logger -LogPath $LogPath -LogNote $LogNote -DateFormat $DateFormat
Start-Logger -NoDateTime
Start-Logger -IsDebug

.NOTES
Log-Debug will only show up if you pass the -IsDebug Switch
#>
function Start-Logging {
  param (
    [Parameter(Position=0)][string]$LogPath="$env:TEMP\PoShLumberjack\log\Lumberjack.log",
    [Parameter(Position=1)][string]$LogNote,
    [Parameter(Position=2)][string]$DateFormat="yyyyMMddHHmmss",
    [Parameter(Position=3)][switch]$IsDebug=$false,
    [Parameter(Position=4)][switch]$NoDateTime=$false

  )

  Write-Verbose "Setting up log file..."
  if (-not (Test-Path $LogPath)) {
    Write-Verbose "  Creating log file: $LogPath"
    $script:FilePath = (Create-LogFile $LogPath $DateFormat $NoDateTime).FullName
    Write-Verbose "  Created log file: $($script:FilePath)"
  }
  $script:IsDebug = $IsDebug
  Write-Verbose "  Log file setup complete"
  if ($LogNote) {
    Log-Info "========================"
    Log-Info "[NOTE] $LogNote"
    Log-Info "========================"
  }
}
#endregion