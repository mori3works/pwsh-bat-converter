# Param��
Param(
    [Parameter(Mandatory = $false)]
    [string] $Message = [string]::Empty
);

Set-PSDebug -Strict;

# ���W���[���̓ǂݍ���
Add-Type -AssemblyName "System.Windows.Forms";
if ($Message -ne [string]::Empty) {
    [Windows.Forms.MessageBox]::Show($Message) | Out-Null;
}

# �V���v���Ȏ�
$intVar = 48;
$floatVar = [float]$intVar + [float]([Random]::New().NextDouble());
Write-Debug -Message $floatVar;

# �q�A�h�L�������g
$msgHereDoc = @"
# �o�b�N�N�H�[�g�{�_���[�}�[�N�A�_���[�}�[�N
`$var $var

# �o�b�N�N�H�[�g�{�_�u���N�H�[�g�A�_�u���N�H�[�g
`"Hello World!`" "Nihao Sijie!"

# �d�˂��_�u���N�H�[�g
"x""X"

# �d�˂��V���O���N�H�[�g
'y''Y'

# �o�b�N�N�H�[�g�{�A���t�@�x�b�g��
A|`a|
B|`b|
C|`c|
D|`d|
E|`e|
F|`f|
G|`g|
H|`h|
I|`i|
J|`j|
K|`k|
L|`l|
M|`m|
N|`n|
O|`o|
P|`p|
Q|`q|
R|`r|
S|`s|
T|`t|
U|`u|
V|`v|
W|`w|
X|`x|
Y|`y|
Z|`z|
`|``|

# �ϐ��W�J
intVar is {0} or ${intVar}
floatVar is $floatVar
hash.Prop is $($hash.Prop)
Env:ALLUSERPROFILE is ${Env:ALLUSERSPROFILE}
1+1 is $(1+1)
1+intVar
"@ -F $intVar;
# {N} �����钆�� '${Name}' �Ŏw�肵�Ă���� -F �����Ƃ���FormatException����������
# �Ȃ̂ŁA''������܂��ɕϐ��W�J������K�v����B

# �N�H�[�g���ꂽ������
$msg1 = "�ʏ�̃_�u���N�H�[�g�̕�����{" + "`"�_�u���N�H�[�g�Ŋ���ꂽ����""" + "�ϐ��W�J intVar=${intVar}, floatVar=$floatVar, hashTable=${Env:ALLUSERSPROFILE}, ���W�J 1+1=$(1+1)";
$msg2 = '�ʏ�̃V���O���N�H�[�g�̕�����{' + '''�V���O���N�H�[�g�Ŋ���ꂽ����''';
$msg3 = "�_�u���N�H�[�g������" + <#�r���ŃR�����g#> [string]::Empty + '�V���O���N�H�[�g������';

# �n�b�V���܂ޕ�����ƃR�����g
$msg4 = "Sheban: #!/usr/bin/bash"   # Sheban
$a = "#";
$b = "#"; #---
$c = "#"; #-"-"-#-"-"-
$d = "<# #>";
$e = "<# #>"; #---
$f = "<# #>"; <# #>
$g = 0; <# """ <# #> #>
$h = <# #> 0; #---

# �o�͊m�F�ƁA�p�C�v���C������
Write-Host -Object $msgHereDoc;
@($msg1, $msg2) | % { Write-Host -Object $_ }
@(($msg3, $True), $($msg4, $True)) | ? { $_[1] } | % {
    Write-Host -Object $_[0];
}
