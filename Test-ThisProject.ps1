Set-PSDebug -Strict;


$testDir = "./t";
$testCases = @(Get-ChildItem -Path $testDir | ? { $_.Name -match '\.ps1$' });


# Convert
foreach ($case in $testCases) {
    $file = $case.FullName;
    powershell -ExecutionPolicy RemoteSigned -File "./ConvertTo-BatchFile.ps1" -SourceFile $file
}


# Execute
foreach ($case in $testCases) {
    $outPs1 = $case.Name + ".ps1_stdout";
    $outPs1File = @('.', 'tmp', $outPs1) -join [IO.Path]::DirectorySeparatorChar;
    powershell -ExecutionPolicy RemoteSigned -File (Join-Path -Path $testDir -ChildPath $case.FullName) > $outPs1File;

    $outBat = $case.Name + ".bat_stdout";
    $outBatFile = @('.', 'tmp', $outBat) -join [IO.Path]::DirectorySeparatorChar;
    ($case.FullName -replace @('\.ps1$', '.bat')) > $outBatFile;
}

# Check
foreach ($case in $testCases) {
    $outPs1 = $case.Name + ".ps1_stdout";
    $outPs1File = @('.', 'tmp', $outPs1) -join [IO.Path]::DirectorySeparatorChar;
    $outBat = $case.Name + ".bat_stdout";
    $outBatFile = @('.', 'tmp', $outBat) -join [IO.Path]::DirectorySeparatorChar;


}

