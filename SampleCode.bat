@ECHO OFF

@SET CODE= ^
 ^<# Param句 #^> ^
Param( ^
    [Parameter(Mandatory = $false)] ^
    [string] $Message = [string]::Empty ^
); ^
 ^
Set-PSDebug -Strict; ^
 ^
 ^<# モジュールの読み込み #^> ^
Add-Type -AssemblyName 'System.Windows.Forms'; ^
if ($Message -ne [string]::Empty) { ^
    [Windows.Forms.MessageBox]::Show($Message) ^| Out-Null; ^
}; ^
 ^
 ^<# シンプルな式 #^> ^
$intVar = 48; ^
$floatVar = [float]$intVar + [float]([Random]::New().NextDouble()); ^
Write-Debug -Message $floatVar; ^
 ^
 ^<# ヒアドキュメント #^> ^
$msgHereDoc = ('intVar is {0} or ${intVar}' + ([Environment]::NewLine) + '1+intVar') -F $intVar; ^
 ^
 ^<# クォートされた文字列 #^> ^
$msg1 = '通常のダブルクォートの文字列＋' + '' + [char]0x22 + 'ダブルクォートで括られた文字' + [char]0x22 + '' + '変数展開 intVar=${intVar}, floatVar=$floatVar, hashTable=${Env:ALLUSERSPROFILE}, 式展開 1+1=$(1+1)'; ^
$msg2 = '通常のシングルクォートの文字列＋' + '''シングルクォートで括られた文字'''; ^
$msg3 = 'ダブルクォート文字列' + ^<#途中でコメント#^> [string]::Empty + 'シングルクォート文字列'; ^
 ^
 ^<# ハッシュ含む文字列とコメント #^> ^
$msg4 = 'Sheban: ' + [char]0x23 + '!/usr/bin/bash'   ; ^<# Sheban #^> ^
$a = '' + [char]0x23 + ''; ^
$b = '' + [char]0x23 + ''; ; ^<#---#^> ^
$c = '' + [char]0x23 + ''; ; ^<#-'-'-#-'-'-#^> ^
$d = '^<' + [char]0x23 + ' ' + [char]0x23 + '^>'; ^
$e = '^<' + [char]0x23 + ' ' + [char]0x23 + '^>'; ; ^<#---#^> ^
$f = '^<' + [char]0x23 + ' ' + [char]0x23 + '^>'; ^<# #^> ^
$g = 0; ^<# ''" ^<# #^> #^> ^
 ^
 ^<# 出力確認と、パイプライン処理 #^> ^
Write-Host -Object $msgHereDoc; ^
@($msg1, $msg2) ^| %% { Write-Host -Object $_ }; ^
@(($msg3, $True), $($msg4, $True)) ^| ? { $_[1] } ^| %% { ^
    Write-Host -Object $_[0]; ^
}; ^
 ^

@ECHO ON
@powershell -ExecutionPolicy ByPass -Command "%CODE%"
@ECHO OFF
