@ECHO OFF

@SET CODE= ^
Param( ^
    [Parameter(Mandatory = $true)] ^
    [string] $Message ^
); ^
 ^
Set-PSDebug -Strict; ^
 ^
Add-Type -AssemblyName 'System.Windows.Forms'; ^
[Windows.Forms.MessageBox]::Show($Message) ^| Out-Null; ^
 ^
$intVar = 48; ^
 ^
$msgHereDoc = 'Set-PSDebug -Strict;' + ([Environment]::NewLine) + '' + ([Environment]::NewLine) + '`$var = ' + [char]0x22 + 'Hello World!' + [char]0x22 + ';' + ([Environment]::NewLine) + 'Write-Host -Object `$var;' + ([Environment]::NewLine) + '' + ([Environment]::NewLine) + '`$intVar = {0};' -F $intVar; ^
 ^
Write-Host -Object $msgHereDoc; ^
 ^
 ^
$prop = Get-ItemProperty -Path 'HKCU:Environment'; ^
Write-Host -Object $prop.Path; ^
 ^
 ^

@ECHO ON
@powershell -ExecutionPolicy ByPass -Command "%CODE%"
@ECHO OFF
