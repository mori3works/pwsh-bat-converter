@ECHO OFF

SET _CONVERTER=.\ConvertTo-BatchFile.ps1
SET _TESTER=.\SampleCode.ps1
SET _TESTER_BAT=.\SampleCode.bat
SET _RESULT_PS1=.\ps1.txt
SET _RESULT_BAT=.\bat.txt

powershell -ExecutionPolicy ByPass -File %_CONVERTER% -SourceFile %_TESTER% -DestinationFile %_TESTER_BAT%

powershell -ExecutionPolicy ByPass -File %_TESTER% > %_RESULT_PS1%
%_TESTER_BAT% > %_RESULT_BAT%
