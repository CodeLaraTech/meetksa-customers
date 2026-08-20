# Automated script to find Flutter SDK on Windows and append to User PATH environment variable

Write-Host "Searching for Flutter SDK on system..." -ForegroundColor Cyan

$candidatePaths = @(
    "C:\src\flutter\bin",
    "C:\flutter\bin",
    "D:\src\flutter\bin",
    "D:\flutter\bin",
    "$env:USERPROFILE\flutter\bin",
    "$env:USERPROFILE\src\flutter\bin",
    "$env:LOCALAPPDATA\flutter\bin",
    "C:\tools\flutter\bin"
)

$foundPath = $null

foreach ($path in $candidatePaths) {
    if (Test-Path "$path\flutter.bat") {
        $foundPath = $path
        break
    }
}

if (-not $foundPath) {
    Write-Host "Searching drive roots for flutter.bat..." -ForegroundColor Yellow
    $foundFile = Get-ChildItem -Path "C:\", "D:\" -Filter "flutter.bat" -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($foundFile) {
        $foundPath = Split-Path -Path $foundFile.FullName -Parent
    }
}

if ($foundPath) {
    Write-Host "Found Flutter SDK at: $foundPath" -ForegroundColor Green

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$foundPath*") {
        $newPath = "$currentPath;$foundPath"
        [Environment]::GetEnvironmentVariable("Path", "User")
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path = "$env:Path;$foundPath"
        Write-Host "SUCCESS: Added Flutter to User PATH environment variable." -ForegroundColor Green
        Write-Host "Please restart PowerShell for changes to take effect." -ForegroundColor Green
    } else {
        Write-Host "Flutter is already present in User PATH." -ForegroundColor Yellow
    }
} else {
    Write-Host "Flutter SDK was not found in common locations." -ForegroundColor Red
    Write-Host "If Flutter is not installed yet, download Flutter SDK from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
}
