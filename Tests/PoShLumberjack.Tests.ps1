Import-Module $PSScriptRoot\..\PoShLumberjack -Force

$DefaultTestLogLocation = "$env:TEMP\PoShLumberjack\log\"

function Assert-FileCreatedWithoutStartLogging {
  param (
    [Parameter(Position=0)][string]$ExpectedLevel,
    [Parameter(Position=1)][string]$ExpectedMessage
  )
  $TestLog = Get-ChildItem $DefaultTestLogLocation
  $TestLog | Should not BeNullorEmpty
  $TestLog.Count | Should be 1
  $TestContent = Get-Content $TestLog.FullName
  $TestPath = Join-Path -Path $DefaultTestLogLocation -ChildPath "Lumberjack.log"

  $TestContent[0] | Should Match "\[\d+\]\[INFO\] =+"
  $TestContent[1] | Should Match "\[\d+\]\[INFO\] \[NOTE\] Start-Logging was not called. Creating log: $($TestPath.ToString() -replace "\\", "\\")"
  $TestContent[2] | Should Match "\[\d+\]\[INFO\] =+"
  $TestContent[3] | Should Match "\[\d+\]\[$ExpectedLevel\] $ExpectedMessage"
}

Describe 'PoSh LumberJack Tests' {
  $BaseTestLogLocation = "TestDrive:\"

  AfterEach {
    if (Test-Path $BaseTestLogLocation) {
      Remove-Item -Path $BaseTestLogLocation -Recurse -Force
    }
    if (Test-Path $DefaultTestLogLocation) {
      $parent = Split-Path $DefaultTestLogLocation -Parent
      Remove-Item -Path $parent -Recurse -Force
    }
  }

  Context 'When no PoShLumberjack functions have been called and there is no existing log file' {

    It 'Start-Logging should successfully creates a new log file' {
      $TestLogLocation = Join-Path $BaseTestLogLocation Lumberjack.log
      Start-Logging $TestLogLocation -NoDateTime
      Test-Path $TestLogLocation | Should be $true
    }

    It "Write-LogI should successfully create a new log file" {
      Test-Path $DefaultTestLogLocation | Should Be $false

      $message = (New-Guid).toString()
      Write-LogI $message

      Assert-FileCreatedWithoutStartLogging "INFO" $message
    }

    It "Write-LogW should successfully create a new log file" {
      Test-Path $DefaultTestLogLocation | Should Be $false

      $message = (New-Guid).toString()
      Write-LogW $message

      Assert-FileCreatedWithoutStartLogging "WARN" $message
    }

    It "Write-LogE should successfully create a new log file" {
      Test-Path $DefaultTestLogLocation | Should Be $false

      $message = (New-Guid).toString()
      Write-LogE $message

      Assert-FileCreatedWithoutStartLogging "ERROR" $message
    }

    It "Write-LogD should NOT create a new log file" {
      Test-Path $DefaultTestLogLocation | Should Be $false
      Write-LogD "Hello, world!"
      Test-Path $DefaultTestLogLocation | Should Be $false
    }
  }
}