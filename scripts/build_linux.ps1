#!/usr/bin/env pwsh

# Build Linux version of Loro FFI library

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

Write-Output "`n=== Building Linux version ==="
Push-Location -Path "$PSScriptRoot/loro-ffi"

# Try to build Linux library using cross-compilation if possible
$linuxBuildSuccess = $false

# Check if cross is available
$crossAvailable = $true
try {
    cross --version > $null 2>&1
} catch {
    $crossAvailable = $false
}

if ($crossAvailable) {
    Write-Output "Using cross for Linux cross-compilation..."
    Write-Output "Running: cross build --release --target x86_64-unknown-linux-gnu"
    Start-Process -FilePath "cross" -ArgumentList "build --release --target x86_64-unknown-linux-gnu" -NoNewWindow -Wait -RedirectStandardOutput "cross_output.txt" -RedirectStandardError "cross_error.txt"
    Get-Content "cross_output.txt" | Write-Output
    Get-Content "cross_error.txt" | Write-Output
    
    # Check if build succeeded
    $linuxLibPath = "target/x86_64-unknown-linux-gnu/release/libloro_ffi.so"
    if (Test-Path $linuxLibPath) {
        Copy-Item -Path $linuxLibPath -Destination "$PSScriptRoot/release/linux/libloro_ffi.so" -Force
        Write-Output "Linux build completed using cross!"
        Write-Output "   Copied to: $PSScriptRoot/release/linux/libloro_ffi.so"
        $linuxBuildSuccess = $true
    }
    
    Remove-Item "cross_output.txt", "cross_error.txt" -Force -ErrorAction SilentlyContinue
} else {
    Write-Output "cross not found. Trying direct cargo build..."
    
    # Check if Docker is available (required for cross)
    $dockerAvailable = $true
try {
    docker --version > $null 2>&1
} catch {
    $dockerAvailable = $false
}
    
    if (-not $dockerAvailable) {
        Write-Output "Docker not found. Cannot use cross without Docker."
    } else {
        Write-Output "Docker found. Installing cross..."
        Start-Process -FilePath "cargo" -ArgumentList "install cross" -NoNewWindow -Wait -RedirectStandardOutput "cross_install_output.txt" -RedirectStandardError "cross_install_error.txt"
        Get-Content "cross_install_output.txt" | Write-Output
        Get-Content "cross_install_error.txt" | Write-Output
        Remove-Item "cross_install_output.txt", "cross_install_error.txt" -Force -ErrorAction SilentlyContinue
        
        # Try to use cross after installation
        try {
            cross --version > $null 2>&1
            $crossAvailable = $true
        } catch {
            $crossAvailable = $false
        }
        
        if ($crossAvailable) {
            Write-Output "Running: cross build --release --target x86_64-unknown-linux-gnu"
            Start-Process -FilePath "cross" -ArgumentList "build --release --target x86_64-unknown-linux-gnu" -NoNewWindow -Wait -RedirectStandardOutput "cross_output.txt" -RedirectStandardError "cross_error.txt"
            Get-Content "cross_output.txt" | Write-Output
            Get-Content "cross_error.txt" | Write-Output
            
            # Check if build succeeded
            $linuxLibPath = "target/x86_64-unknown-linux-gnu/release/libloro_ffi.so"
            if (Test-Path $linuxLibPath) {
                Copy-Item -Path $linuxLibPath -Destination "$PSScriptRoot/release/linux/libloro_ffi.so" -Force
                Write-Output "Linux build completed using cross!"
                Write-Output "   Copied to: $PSScriptRoot/release/linux/libloro_ffi.so"
                $linuxBuildSuccess = $true
            }
            
            Remove-Item "cross_output.txt", "cross_error.txt" -Force -ErrorAction SilentlyContinue
        }
    }
}

# If cross build failed, try direct cargo build as fallback
if (-not $linuxBuildSuccess) {
    Write-Output "Adding Linux target architecture..."
    Start-Process -FilePath "rustup" -ArgumentList "target add x86_64-unknown-linux-gnu" -NoNewWindow -Wait -RedirectStandardOutput "rustup_target_output.txt" -RedirectStandardError "rustup_target_error.txt"
    Get-Content "rustup_target_output.txt" | Write-Output
    Get-Content "rustup_target_error.txt" | Write-Output
    Remove-Item "rustup_target_output.txt", "rustup_target_error.txt" -Force -ErrorAction SilentlyContinue
    
    Write-Output "Running: cargo build --release --target x86_64-unknown-linux-gnu"
    Start-Process -FilePath "cargo" -ArgumentList "build --release --target x86_64-unknown-linux-gnu" -NoNewWindow -Wait -RedirectStandardOutput "cargo_linux_output.txt" -RedirectStandardError "cargo_linux_error.txt"
    $cargoOutput = Get-Content "cargo_linux_output.txt" -Raw
    $cargoError = Get-Content "cargo_linux_error.txt" -Raw
    Write-Output $cargoOutput
    Write-Output $cargoError
    
    # Check if build succeeded
    $linuxLibPath = "target/x86_64-unknown-linux-gnu/release/libloro_ffi.so"
    if (Test-Path $linuxLibPath) {
        Copy-Item -Path $linuxLibPath -Destination "$PSScriptRoot/release/linux/libloro_ffi.so" -Force
        Write-Output "Linux build completed!"
        Write-Output "   Copied to: $PSScriptRoot/release/linux/libloro_ffi.so"
        $linuxBuildSuccess = $true
    } else {
        Write-Output "Linux build failed, .so file not found"
        Write-Output "   Expected path: $linuxLibPath"
        
        # Check if error is about missing linker
        if ($cargoError -match 'linker "cc" not found') {
            Write-Output "   Error: Missing Linux linker. This is expected when building Linux libraries on Windows."
            Write-Output "   Solutions:"
            Write-Output "   1. Install WSL (Windows Subsystem for Linux) and run the script from WSL"
            Write-Output "   2. Install Docker and cross tool (https://github.com/cross-rs/cross)"
            Write-Output "   3. Build Linux libraries directly on a Linux system"
        }
    }
    
    Remove-Item "cargo_linux_output.txt", "cargo_linux_error.txt" -Force -ErrorAction SilentlyContinue
}

# Return to original directory
Pop-Location
