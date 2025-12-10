#!/usr/bin/env pwsh

# Build Dart library (get dependencies and run analysis)

param(
    [string]$ProjectRoot
)

# Determine the project root directory
if ([string]::IsNullOrEmpty($ProjectRoot)) {
    # If no project root provided, find it by traversing up from the script directory
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ProjectRoot = $scriptDir
    
    # Traverse up until we find the project root (containing Cargo.toml)
    while ($ProjectRoot -ne "" -and -not (Test-Path "$ProjectRoot/Cargo.toml" -PathType Leaf) -and -not (Test-Path "$ProjectRoot/pubspec.yaml" -PathType Leaf)) {
        $ProjectRoot = Split-Path -Parent $ProjectRoot
        if ($ProjectRoot -eq "") {
            Write-Error "Could not find project root directory. Please run this script from the project directory or provide the -ProjectRoot parameter."
            exit 1
        }
    }
}

$PSScriptRoot = $ProjectRoot

Write-Output "`n=== Building Dart library ==="

# Get Dart dependencies
Write-Output "Running: dart pub get"
Start-Process -FilePath "dart" -ArgumentList "pub get" -NoNewWindow -Wait -RedirectStandardOutput "dart_get_output.txt" -RedirectStandardError "dart_get_error.txt"
Get-Content "dart_get_output.txt" | Write-Output
Get-Content "dart_get_error.txt" | Write-Output
Remove-Item "dart_get_output.txt", "dart_get_error.txt" -Force -ErrorAction SilentlyContinue

# Run Dart analysis
Write-Output "Running: dart analyze"
Start-Process -FilePath "dart" -ArgumentList "analyze" -NoNewWindow -Wait -RedirectStandardOutput "dart_analyze_output.txt" -RedirectStandardError "dart_analyze_error.txt"
Get-Content "dart_analyze_output.txt" | Write-Output
Get-Content "dart_analyze_error.txt" | Write-Output
Remove-Item "dart_analyze_output.txt", "dart_analyze_error.txt" -Force -ErrorAction SilentlyContinue

# Get Flutter dependencies
Write-Output "Running: flutter pub get"
Start-Process -FilePath "flutter" -ArgumentList "pub get" -NoNewWindow -Wait -RedirectStandardOutput "flutter_get_output.txt" -RedirectStandardError "flutter_get_error.txt"
Get-Content "flutter_get_output.txt" | Write-Output
Get-Content "flutter_get_error.txt" | Write-Output
Remove-Item "flutter_get_output.txt", "flutter_get_error.txt" -Force -ErrorAction SilentlyContinue

# Run Flutter analysis
Write-Output "Running: flutter analyze"
Start-Process -FilePath "flutter" -ArgumentList "analyze" -NoNewWindow -Wait -RedirectStandardOutput "flutter_analyze_output.txt" -RedirectStandardError "flutter_analyze_error.txt"
Get-Content "flutter_analyze_output.txt" | Write-Output
Get-Content "flutter_analyze_error.txt" | Write-Output
Remove-Item "flutter_analyze_output.txt", "flutter_analyze_error.txt" -Force -ErrorAction SilentlyContinue
