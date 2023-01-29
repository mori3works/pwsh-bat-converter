# Converter to BAT file for PowerShell script

## What is this

PowerShellスクリプトの内容をbatファイルに記述することで  
GUI環境においてはダブルクリックで実行できる形式に変換する。  
（cmd.exeでは直接ファイル名を指定するだけで実行できるようになる）

## How to use

### 1. Convert PowerShell Script to Batch file

```bash
PowerShell -ExecutionPolicy RemoteSigned -File ConvertTo-BatchFile.ps1 -SourceFile SampleCode.ps1 -DestinationFile SampleCode.bat
```

DestinationFileは任意。  
省略した場合はSourceFileのファイル名の拡張子をbatに変更したファイル名で保存される。  

### 2. Run it with double click or cmd.exe

```bach
cmd.exe /c SampleCode.bat
```

