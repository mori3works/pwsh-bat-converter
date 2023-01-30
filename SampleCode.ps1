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
`$quote = "o""o";
``dir``
a`nb`rc

"@ -F $intVar;

$msgDQuoted = "`"Hello World`"`n`$1 = \135";

$msgDupDQuote = "A""A";
$msgDupSQuote = 'B''B';

Write-Host -Object $msgHereDoc;
$msgDQuoted | Write-Host;
@($msgDupDQuote, $msgDupSQuote) | % { Write-Host -Object $_ }

$prop = Get-ItemProperty -Path "HKCU:Environment";
Write-Host -Object $prop.Path;

