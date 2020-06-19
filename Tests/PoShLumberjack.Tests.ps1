Import-Module $PSScriptRoot\..\PoShLumberjack -Force

Describe 'Start-Logging' {
  Context 'Test Start-Logging ' {
    It 'should create a new log using all parameters' {
      $TestLogLocation = "TestDrive:\lumberjack.log"
      Start-Logging $TestLogLocation -NoDateTime
      Test-Path $TestLogLocation | Should be $True
    }
  }
}