$script:FilePath
$script:LevelColors = @{INFO='White'; WARN='Yellow'; ERROR='Red'; DEBUG='Cyan'}
$script:IsDebug = $false

#region accessor functions
function Set-LevelTextColor {
  param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
    [String]
    $tag,
    [Parameter(Mandatory=$true, Position=1)]
    [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
    [String]
    $color
  )
  $script:LevelColors.$tag = $color
  Write-Host "Set $tag to $color"
}

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
      [Parameter(Position=1)][string]$tag="INFO"
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
function Log-Info {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  Write-Log $Message "INFO"
}

function Log-Warn {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  Write-Log $Message "WARN"
}

function Log-Error {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  Write-Log $Message "ERROR"
}

function Log-Debug {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Message
  )
  if ($script:isDebug) {
    Write-Log $Message "DEBUG"
  }
}

function Start-Logging {
  param (
    [Parameter(Position=0)][string]$LogPath="$env:TEMP\PoShLumberjack\log\Lumberjack.log",
    [Parameter(Position=1)][string]$LogNote,
    [Parameter(Position=2)][string]$dateFormat="yyyyMMddHHmmss",
    [Parameter(Position=3)][switch]$IsDebug=$false,
    [Parameter(Position=4)][switch]$NoDateTime=$false

  )

  Write-Verbose "Setting up log file..."
  if (-not (Test-Path $LogPath)) {
    Write-Verbose "  Creating log file: $LogPath"
    $script:FilePath = (Create-LogFile $LogPath $dateFormat $NoDateTime).FullName
    Write-Verbose "  Created log file: $($script:FilePath)"
  }
  $script:IsDebug = $IsDebug
  Write-Verbose "  Log file setup complete"
  if ($LogNote) {
    Log-Info "[NOTE] $LogNote"
  }
}
#endregion