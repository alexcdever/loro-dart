#!/usr/bin/env pwsh

# Save original directory
$originalDir = Get-Location

Write-Output "Starting to build Loro FFI library..."

# Create release directories
$releaseDir = "$PSScriptRoot/release"
New-Item -ItemType Directory -Path "$releaseDir/windows" -Force | Out-Null
New-Item -ItemType Directory -Path "$releaseDir/linux" -Force | Out-Null
New-Item -ItemType Directory -Path "$releaseDir/android/arm64-v8a" -Force | Out-Null
New-Item -ItemType Directory -Path "$releaseDir/android/armeabi-v7a" -Force | Out-Null
New-Item -ItemType Directory -Path "$releaseDir/android/x86_64" -Force | Out-Null
New-Item -ItemType Directory -Path "$releaseDir/android/x86" -Force | Out-Null

# Call platform-specific build scripts
& "$PSScriptRoot/scripts/build_windows.ps1" -ProjectRoot $PSScriptRoot
& "$PSScriptRoot/scripts/build_linux.ps1" -ProjectRoot $PSScriptRoot
& "$PSScriptRoot/scripts/build_android.ps1" -ProjectRoot $PSScriptRoot

# === Build summary ===
Write-Output "`n=== Build completed ==="
Write-Output "Build results are in the release directory:"

$finalWinDllPath = "$PSScriptRoot/release/windows/loro_ffi.dll"
if (Test-Path $finalWinDllPath) {
    Write-Output "Windows: $finalWinDllPath"
} else {
    Write-Output "Windows: DLL not found"
}

# Check Android build results
$androidArchs = @("arm64-v8a", "armeabi-v7a", "x86", "x86_64")
foreach ($arch in $androidArchs) {
    $androidLibPath = "$PSScriptRoot/release/android/$arch/libloro_ffi.so"
    if (Test-Path $androidLibPath) {
        Write-Output "Android ${arch}: $androidLibPath"
    } else {
        Write-Output "Android ${arch}: .so file not found"
    }
}

# Check Linux build result
$linuxLibPath = "$PSScriptRoot/release/linux/libloro_ffi.so"
if (Test-Path $linuxLibPath) {
    Write-Output "Linux: $linuxLibPath"
} else {
    Write-Output "Linux: .so file not found"
}

# Call Dart library build script
& "$PSScriptRoot/scripts/build_dart.ps1" -ProjectRoot $PSScriptRoot

Write-Output "`n=== All builds completed successfully! ==="
