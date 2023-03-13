# Param句
Param(
    [Parameter(Mandatory = $false)]
    [string] $Message = [string]::Empty
);

Set-PSDebug -Strict;

# モジュールの読み込み
Add-Type -AssemblyName "System.Windows.Forms";
if ($Message -ne [string]::Empty) {
    [Windows.Forms.MessageBox]::Show($Message) | Out-Null;
}

# シンプルな式
$intVar = 48;
$floatVar = [float]$intVar + [float]([Random]::New().NextDouble());
Write-Debug -Message $floatVar;

# ヒアドキュメント
$msgHereDoc = @"
# バッククォート＋ダラーマーク、ダラーマーク
`$var $var

# バッククォート＋ダブルクォート、ダブルクォート
`"Hello World!`" "Nihao Sijie!"

# 重ねたダブルクォート
"x""X"

# 重ねたシングルクォート
'y''Y'

# バッククォート＋アルファベット等
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

# 変数展開
intVar is {0} or ${intVar}
floatVar is $floatVar
hash.Prop is $($hash.Prop)
Env:ALLUSERPROFILE is ${Env:ALLUSERSPROFILE}
1+1 is $(1+1)
1+intVar
"@ -F $intVar;
# {N} がある中に '${Name}' で指定していると -F したときにFormatExceptionが発生する
# なので、''化するまえに変数展開させる必要あり。

# クォートされた文字列
$msg1 = "通常のダブルクォートの文字列＋" + "`"ダブルクォートで括られた文字""" + "変数展開 intVar=${intVar}, floatVar=$floatVar, hashTable=${Env:ALLUSERSPROFILE}, 式展開 1+1=$(1+1)";
$msg2 = '通常のシングルクォートの文字列＋' + '''シングルクォートで括られた文字''';
$msg3 = "ダブルクォート文字列" + <#途中でコメント#> [string]::Empty + 'シングルクォート文字列';

# ハッシュ含む文字列とコメント
$msg4 = "Sheban: #!/usr/bin/bash"   # Sheban
$a = "#";
$b = "#"; #---
$c = "#"; #-"-"-#-"-"-
$d = "<# #>";
$e = "<# #>"; #---
$f = "<# #>"; <# #>
$g = 0; <# """ <# #> #>
$h = <# #> 0; #---

# 出力確認と、パイプライン処理
Write-Host -Object $msgHereDoc;
@($msg1, $msg2) | % { Write-Host -Object $_ }
@(($msg3, $True), $($msg4, $True)) | ? { $_[1] } | % {
    Write-Host -Object $_[0];
}
