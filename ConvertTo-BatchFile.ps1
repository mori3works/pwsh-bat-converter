Param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $SourceFile,

    [Parameter(Mandatory = $false, Position = 2)]
    [string] $DestinationFile = [string]::Empty
);

Set-PSDebug -Strict;
#$DebugPreference = "Continue";

if (!(Test-Path -Path $SourceFile)) {
    Write-Error -Message ("Source file '{}' is not readable." -F $SourceFile);
}

if ($DestinationFile -eq [string]::Empty) {
    $DestinationFile = $SourceFile -replace @('\.ps1$', '.bat');
}

$ESC_NEWLINE = " ^";
$ESC_DQUOTE = '`"';

$PAT_BEGIN_HEREDOC = '@"$';
$PAT_END_HEREDOC = '^"@';
$PAT_DQUOTED_STRING = '"(((?<=`)"|[^"])*)"';

$builder = [Text.StringBuilder]::New();
[void]$builder.AppendLine("@ECHO OFF");
[void]$builder.AppendLine();
[void]$builder.AppendLine("@SET CODE=" + $ESC_NEWLINE);
$inHereDoc = $false;
$firstInHereDoc = $false;
$prefixHereDoc = [string]::Empty;
$bufHereDoc = [Text.StringBuilder]::New();
foreach($line in (Get-Content -Path $SourceFile)) {

    # �G�X�P�[�v���K�v�ȋL���̓G�X�P�[�v����
    $line = $line.Replace("|", "^|");
    $line = $line.Replace(">", "^>");

    # TODO:
    # - �q�A�h�L�������g�ł��_�u���N�H�[�g�����񒆂ł��A�G�X�P�[�v���������̂܂܂ɂȂ��Ă��܂��Ă���B
    #   ex. `$ => `$

    # �q�A�h�L�������g�̏���
    # �q�A�h�L�������g�͑Ή����Ă��Ȃ��̂ŁA���ׂ�1��̕�����ɒu��������
    if ($inHereDoc) {
        if ($line -match $PAT_END_HEREDOC) {
            $inHereDoc = $false;
            Write-Debug -Message "Exit here-document";
            $line = $prefixHereDoc + $bufHereDoc.ToString() + ($line -replace @($PAT_END_HEREDOC, [string]::Empty));
            if (!($line -match ';\s*$')) {
                $line += ";";
            }
            [void]$bufHereDoc.Clear();
        } else {
            # �q�A�h�L�������g�̍ŏ��̍s�������O�ɉ��s������Ȃ�
            # ����ȊO�̍s�͉��s������ϊ�����������
            if (!$firstInHereDoc) {
                [void]$bufHereDoc.Append(' + ([Environment]::NewLine) + ');
            }
            # �G�X�P�[�v����Ă���_�u���N�H�[�g��ϊ�����
            $line = $line -replace @($ESC_DQUOTE, ("' + [char]0x22 + '"));
            # ��������N�H�[�g���A��������
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

        # �_�u���N�H�[�g�̏���
        # ������`�����N��؂�o���A�`�����N�̐擪�Ɩ����̃_�u���N�H�[�g���V���O���N�H�[�g�ɕϊ�����
        for(;;) {
            # �G�X�P�[�v���ꂽ�_�u���N�H�[�g��ϊ�����
            $m = ([regex]$PAT_DQUOTED_STRING).Match($line);
            if (!($m.Success)) { break; }
            $qstr = "'" + ($m.Groups[1].Value.Replace($ESC_DQUOTE, ("' + [char]0x22 + '"))) + "'";

            # �����Ɛ擪�ɃV���O���N�H�[�g������
            $line = $line.Replace($m.Groups[0].Value, $qstr);
        }
    }

    # �����ɃL�����b�g
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