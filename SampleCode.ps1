Param(
    [Parameter(Mandatory = $true)]
    [string] $Message
);

Set-PSDebug -Strict;

Add-Type -AssemblyName "System.Windows.Forms";
[Windows.Forms.MessageBox]::Show($Message) | Out-Null;

$intVar = 48;

$msgHereDoc = @"
Set-PSDebug -Strict;

`$var = `"Hello World!`";
Write-Host -Object `$var;

`$intVar = {0};
"@ -F $intVar;

Write-Host -Object $msgHereDoc;


$prop = Get-ItemProperty -Path "HKCU:Environment";
Write-Host -Object $prop.Path;

