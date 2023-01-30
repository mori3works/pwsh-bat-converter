@ECHO OFF

@SET CODE= ^
Param( ^
    [Parameter(Mandatory = $false)] ^
    [string] $Message = [string]::Empty ^
); ^
 ^
Set-PSDebug -Strict; ^
 ^
Add-Type -AssemblyName 'System.Windows.Forms'; ^
if ($Message -ne [string]::Empty) { ^
    [Windows.Forms.MessageBox]::Show($Message) ^| Out-Null; ^
}; ^
 ^
$intVar = 48; ^
 ^
$msgHereDoc = ('Set-PSDebug -Strict;' + ([Environment]::NewLine) + '' + ([Environment]::NewLine) + '$var = ' + [char]0x22 + 'Hello World!' + [char]0x22 + ';' + ([Environment]::NewLine) + 'Write-Host -Object $var;' + ([Environment]::NewLine) + '' + ([Environment]::NewLine) + '$intVar = {0};' + ([Environment]::NewLine) + '$quote = ' + [char]0x22 + 'o' + [char]0x22 + '' + [char]0x22 + 'o' + [char]0x22 + ';' + ([Environment]::NewLine) + '`dir`' + ([Environment]::NewLine) + 'a' + [char]0x0a + 'b' + [char]0x0d + 'c' + ([Environment]::NewLine) + '') -F $intVar; ^
 ^
$msgDQuoted = '' + [char]0x22 + 'Hello World' + [char]0x22 + '' + [char]0x0a + '$1 = \135'; ^
 ^
$msgDupDQuote = 'A' + [char]0x22 + 'A'; ^
$msgDupSQuote = 'B''B'; ^
 ^
Write-Host -Object $msgHereDoc; ^
$msgDQuoted ^| Write-Host; ^
@($msgDupDQuote, $msgDupSQuote) ^| %% { Write-Host -Object $_ }; ^
 ^
$prop = Get-ItemProperty -Path 'HKCU:Environment'; ^
Write-Host -Object $prop.Path; ^
 ^
 ^

@ECHO ON
@powershell -ExecutionPolicy ByPass -Command "%CODE%"
@ECHO OFF
