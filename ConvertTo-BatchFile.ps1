Param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $SourceFile,

    [Parameter(Mandatory = $false, Position = 2)]
    [string] $DestinationFile = [string]::Empty
);

Set-PSDebug -Strict;
$DebugPreference = "Continue";

if (!(Test-Path -Path $SourceFile)) {
    Write-Error -Message ("Source file '{}' is not readable." -F $SourceFile);
}

if ($DestinationFile -eq [string]::Empty) {
    $DestinationFile = $SourceFile -replace @('\.ps1$', '.bat');
}

$ESC_NEWLINE = " ^";
$ESC_DQUOTE = '`"';
$DUP_DQUOTE = '""';
$DUP_SQUOTE = "''";
$NL = '([Environment]::NewLine)';
$DQ = '[char]0x22';
$SQ = '[char]0x27';
$CR = '[char]0x0d';
$LF = '[char]0x0a';
$HS = '[char]0x23';

$PAT_BEGIN_HEREDOC = '@"$';
$PAT_END_HEREDOC = '^"@';
$PAT_DQUOTED_STRING = '"(((?<!`)""|(?<=`)"|[^"])*)"';

$PAT_SIMPLE_COMMENT = '^([^#]*)(?<!<)#(?!>)(.*)$';
$PAT_QUOTED_HASH = "(`"|')((#|(?<!`)`"`"|(?<=`)`"|[^`"])*)(`"|')";
$PAT_QUOTED_STRING = '("(((?<!)""|(?<=`)"|[^"])*)"|''((''''|[^''])*)'')';

$builder = [Text.StringBuilder]::New();
[void]$builder.AppendLine("@ECHO OFF");
[void]$builder.AppendLine();
[void]$builder.AppendLine("@SET CODE=" + $ESC_NEWLINE);
$inHereDoc = $false;
$firstInHereDoc = $false;
$prefixHereDoc = [string]::Empty;
$bufHereDoc = [Text.StringBuilder]::New();
foreach($line in (Get-Content -Path $SourceFile)) {
    # TODO: 
    #$h = <# #> 0; #---

    # 文字列に#が含まれる行は扱いが複雑になるので、いったん#を置換する
    # ヒアドキュメント中はいったん対象外
    if (($m = ([regex]$PAT_QUOTED_STRING).Matches($line)).Success -and ($m.Groups[2].Value -match "#" -or $m.Groups[4].Value -match "#")) {
        if ($m.Groups[2].Value -ne [string]::Empty) {
            $q = $m.Groups[2].Value.Replace("#", '" + ' + $HS + ' + "');
            $s = $m.Groups[2].Index;
            $e = $s + $m.Groups[2].Length;
        } else {
            $q = $m.Groups[4].Value.Replace("#", "' + " + $HS + " + '");
            $s = $m.Groups[4].Index;
            $e = $s + $m.Groups[4].Length;
        }
        $line = $line.SubString(0, $s) + $q + $line.SubString($e);
    }

    # #が途中から出た場合、シンプルなコメントとみなし、<##>で括る
    if ($line -match $PAT_SIMPLE_COMMENT) {
        $m = ([regex]$PAT_SIMPLE_COMMENT).Matches($line);
        if (!($m.Success)) { ; } else {
            $c = $m.Groups[2].Value;
            if ($c.Length -gt 1 -and $c[0] -eq ' ') {
                $c = $c + ' ';
            }
            # 改行直後に^<#がくると正しく解釈されないので頭にスペースを足す
            if ($m.Groups[1].Value -eq [string]::Empty) {
                $line = " <#" + $c + "#>";
            } else {
                $line = $m.Groups[1].Value + "; <#" + $c + "#>"
            }
            Write-Debug -Message ")) $line";
        }

        #for (;;) {
        #    $m = ([regex]$PAT_QUOTED_HASH).Match($l);
        #    if (!($m.Success)) { break; }
        #    Write-Host -Object $m;
        #    Start-Sleep 1;
        #    $s = $l.Replace($m.Groups[2].Value, [string]::Empty);
        #    $l = $l.Replace($m.Groups[0].Value, $s);
        #
        #Write-Debug -Message "#-- $l";
    }

    # エスケープが必要な記号はエスケープする
    $line = $line.Replace("|", "^|");
    $line = $line.Replace(">", "^>");
    $line = $line.Replace("<", "^<");
    $line = $line.Replace("%", "%%");

    # ヒアドキュメントの処理
    # ヒアドキュメントは対応していないので、すべて1列の文字列に置き換える
    if ($inHereDoc) {
        if ($line -match $PAT_END_HEREDOC) {
            $inHereDoc = $false;
            Write-Debug -Message "Exit here-document";
            $line = $prefixHereDoc + '(' + $bufHereDoc.ToString() + ')' + ($line -replace @($PAT_END_HEREDOC, [string]::Empty));
            if (!($line -match ';\s*$')) {
                $line += ";";
            }
            [void]$bufHereDoc.Clear();
        } else {
            # ヒアドキュメントの最初の行だけ直前に改行が入らない
            # それ以外の行は改行文字を変換し結合する
            if (!$firstInHereDoc) {
                [void]$bufHereDoc.Append(' + ' + $NL + ' + ^');
                [void]$bufHereDoc.Append([Environment]::NewLine);
            }
            # シングルクォートも重なると厄介なので変換する
            $line = $line.Replace("'", ("' + " + $SQ + " + '"));
            # ヒアドキュメント中のダブルクォートはエスケープはするが重ねはそのまま評価され、通常の文字とは少々扱いがことなるためここで処理する
            $line = $line -replace @($ESC_DQUOTE, ("' + " + $DQ + " + '"));
            $line = $line.Replace('"', ("' + " + $DQ + " + '"));
            # エスケープされている文字のエスケープを解除する
            $line = $line.Replace('``', '`');
            $line = $line.Replace('`$', '$');
            $line = $line.Replace('`n', ("' + " + $LF + " + '"));
            $line = $line.Replace('`r', ("' + " + $CR + " + '"));
            # 文字列をクォートし、くっつける
            $line = "'" + $line + "'";
            [void]$bufHereDoc.Append($line);
            $firstInHereDoc = $false;
            continue;
        }
    } else {
        if ($line -match $PAT_BEGIN_HEREDOC) {
            $inHereDoc = $true;
            $firstInHereDoc = $true;
            Write-Debug -Message "Enter here-document";
            $prefixHereDoc = $line -replace @($PAT_BEGIN_HEREDOC, [string]::Empty);
            continue;
        }

        # ダブルクォートで括られた文字列の処理
        # 文字列チャンクを切り出し、チャンクの先頭と末尾のダブルクォートをシングルクォートに変換する
        for (;;) {
            $m = ([regex]$PAT_DQUOTED_STRING).Match($line);
            if (!($m.Success)) { break; }

            # エスケープされたダブルクォートを変換
            # 末尾と先頭にシングルクォートをつける
            $qstr = "'" + ($m.Groups[1].Value.Replace($ESC_DQUOTE, ("' + " + $DQ + " + '"))) + "'";
            # 重ねられたシングルクォートの処理
            #$qstr = $qstr.Replace($DUP_SQUOTE, ("' + " + $SQ + " + '"));
            # 重ねられたダブルクォートの処理
            $qstr = $qstr.Replace($DUP_DQUOTE, ("' + " + $DQ + " + '"));
            # エスケープされている文字のエスケープを解除する
            $qstr = $qstr.Replace('``', '`');
            $qstr = $qstr.Replace('`$', '$');
            $qstr = $qstr.Replace('`n', ("' + " + $LF + " + '"));
            $qstr = $qstr.Replace('`r', ("' + " + $CR + " + '"));

            $line = $line.Replace($m.Groups[0].Value, $qstr);
        }
    }

    # 末尾にセミコロンがなかった場合付与
    if ($line -match '}(?!\s*;\s*)$') { $line = $line + ";" }

    # 末尾にキャレット
    $line = $line + $ESC_NEWLINE;

    [void]$builder.AppendLine("$line");
}
[void]$builder.AppendLine($ESC_NEWLINE);
[void]$builder.AppendLine();
[void]$builder.AppendLine("@ECHO ON");

#Write-Host -Object 'ECHO "%CODE%"';
#Write-Host -Object "@ECHO OFF";
[void]$builder.AppendLine('@powershell -ExecutionPolicy ByPass -Command "%CODE%"');
[void]$builder.AppendLine("@ECHO OFF");


$code = $builder.ToString();
$builder.Clear();

$writer = [IO.StreamWriter]::New($DestinationFile, $false, [Text.Encoding]::GetEncoding("shift_jis"));
$writer.Write($code);
$writer.Close();

Write-Debug -Message $code;

Exit;
