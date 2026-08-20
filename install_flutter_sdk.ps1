# Automated Flutter SDK Installer for Windows
$ErrorActionPreference = "Stop"

$targetParentDir = "C:\src"
$targetFlutterDir = "$targetParentDir\flutter"
$zipPath = "$env:TEMP\flutter_windows_stable.zip"
$flutterDownloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MeetKSA Customer - Flutter SDK Installer  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path "$targetFlutterDir\bin\flutter.bat") {
    Write-Host "Flutter SDK already exists at: $targetFlutterDir" -ForegroundColor Green
} else {
    if (-not (Test-Path $targetParentDir)) {
        New-Item -ItemType Directory -Path $targetParentDir -Force | Out-Null
    }

    Write-Host "Downloading Flutter SDK stable package from Google CDN..." -ForegroundColor Yellow
    Write-Host "URL: $flutterDownloadUrl" -ForegroundColor Gray
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $flutterDownloadUrl -OutFile $zipPath -UseBasicParsing

    Write-Host "Extracting Flutter SDK to $targetParentDir (this may take a minute)..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $targetParentDir -Force

    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Write-Host "Extraction completed successfully." -ForegroundColor Green
}

$flutterBin = "$targetFlutterDir\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$flutterBin*") {
    Write-Host "Adding $flutterBin to User PATH..." -ForegroundColor Yellow
    $newUserPath = "$userPath;$flutterBin"
    [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    $env:Path = "$env:Path;$flutterBin"
    Write-Host "PATH updated successfully." -ForegroundColor Green
} else {
    Write-Host "Flutter bin is already in User PATH." -ForegroundColor Green
}

Write-Host "Testing Flutter CLI..." -ForegroundColor Cyan
& "$flutterBin\flutter.bat" --version
