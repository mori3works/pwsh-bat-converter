@ECHO OFF

@SET CODE= ^
 ^<# Param�� #^> ^
Param( ^
    [Parameter(Mandatory = $false)] ^
    [string] $Message = [string]::Empty ^
); ^
 ^
Set-PSDebug -Strict; ^
 ^
 ^<# ���W���[���̓ǂݍ��� #^> ^
Add-Type -AssemblyName 'System.Windows.Forms'; ^
if ($Message -ne [string]::Empty) { ^
    [Windows.Forms.MessageBox]::Show($Message) ^| Out-Null; ^
}; ^
 ^
 ^<# �V���v���Ȏ� #^> ^
$intVar = 48; ^
$floatVar = [float]$intVar + [float]([Random]::New().NextDouble()); ^
Write-Debug -Message $floatVar; ^
 ^
 ^<# �q�A�h�L�������g #^> ^
$msgHereDoc = ('intVar is {0} or ${intVar}' + ([Environment]::NewLine) + '1+intVar') -F $intVar; ^
 ^
 ^<# �N�H�[�g���ꂽ������ #^> ^
$msg1 = '�ʏ�̃_�u���N�H�[�g�̕�����{' + '' + [char]0x22 + '�_�u���N�H�[�g�Ŋ���ꂽ����' + [char]0x22 + '' + '�ϐ��W�J intVar=${intVar}, floatVar=$floatVar, hashTable=${Env:ALLUSERSPROFILE}, ���W�J 1+1=$(1+1)'; ^
$msg2 = '�ʏ�̃V���O���N�H�[�g�̕�����{' + '''�V���O���N�H�[�g�Ŋ���ꂽ����'''; ^
$msg3 = '�_�u���N�H�[�g������' + ^<#�r���ŃR�����g#^> [string]::Empty + '�V���O���N�H�[�g������'; ^
 ^
 ^<# �n�b�V���܂ޕ�����ƃR�����g #^> ^
$msg4 = 'Sheban: ' + [char]0x23 + '!/usr/bin/bash'   ; ^<# Sheban #^> ^
$a = '' + [char]0x23 + ''; ^
$b = '' + [char]0x23 + ''; ; ^<#---#^> ^
$c = '' + [char]0x23 + ''; ; ^<#-'-'-#-'-'-#^> ^
$d = '^<' + [char]0x23 + ' ' + [char]0x23 + '^>'; ^
$e = '^<' + [char]0x23 + ' ' + [char]0x23 + '^>'; ; ^<#---#^> ^
$f = '^<' + [char]0x23 + ' ' + [char]0x23 + '^>'; ^<# #^> ^
$g = 0; ^<# ''" ^<# #^> #^> ^
 ^
 ^<# �o�͊m�F�ƁA�p�C�v���C������ #^> ^
Write-Host -Object $msgHereDoc; ^
@($msg1, $msg2) ^| %% { Write-Host -Object $_ }; ^
@(($msg3, $True), $($msg4, $True)) ^| ? { $_[1] } ^| %% { ^
    Write-Host -Object $_[0]; ^
}; ^
 ^

@ECHO ON
@powershell -ExecutionPolicy ByPass -Command "%CODE%"
@ECHO OFF
