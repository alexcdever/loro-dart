#!/usr/bin/env pwsh

# Build Windows version of Loro FFI library

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

Write-Output "`n=== Building Windows version ==="
Push-Location -Path "$PSScriptRoot/loro-ffi"

# Build the library
Write-Output "Running: cargo build --release --target x86_64-pc-windows-msvc"
Start-Process -FilePath "cargo" -ArgumentList "build --release --target x86_64-pc-windows-msvc" -NoNewWindow -Wait -RedirectStandardOutput "cargo_output.txt" -RedirectStandardError "cargo_error.txt"
Get-Content "cargo_output.txt" | Write-Output
Get-Content "cargo_error.txt" | Write-Output
Remove-Item "cargo_output.txt", "cargo_error.txt" -Force -ErrorAction SilentlyContinue

# Check build result
$windowsLibDir = "target/x86_64-pc-windows-msvc/release"
$winDllPath = "$windowsLibDir/loro_ffi.dll"

if (Test-Path $winDllPath) {
    Copy-Item -Path $winDllPath -Destination "$PSScriptRoot/release/windows/loro_ffi.dll" -Force
    Copy-Item -Path $winDllPath -Destination "$PSScriptRoot/loro_ffi.dll" -Force
    Write-Output "Windows build completed!"
    Write-Output "   Copied to: $PSScriptRoot/release/windows/loro_ffi.dll"
    Write-Output "   Copied to: $PSScriptRoot/loro_ffi.dll"
} else {
    Write-Output "Windows build failed, DLL not found"
    Write-Output "   Expected path: $winDllPath"
    if (Test-Path $windowsLibDir) {
        Write-Output "   Build directory content:"
        Get-ChildItem -Path $windowsLibDir | Format-Table -AutoSize
    }
}

# Return to original directory
Pop-Location
