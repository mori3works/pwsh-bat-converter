@ECHO OFF

@SET CODE= ^
$message = 'Hello, World!'; ^
 ^
Write-Host -Object $mssage; ^
 ^
 ^

@ECHO ON
@powershell -ExecutionPolicy ByPass -Command "%CODE%"
@ECHO OFF
