#!/usr/bin/env pwsh

# Build Android versions of Loro FFI library

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

Write-Output "`n=== Building Android versions ==="

# Check if rustup is available
$rustupAvailable = $true
try {
    rustup --version > $null 2>&1
} catch {
    $rustupAvailable = $false
}

if (-not $rustupAvailable) {
    Write-Output "rustup not found. Please install rustup from https://rustup.rs/"
} else {
    # Find NDK path
    $sdkPath = "C:\Users\alexc\AppData\Local\Android\sdk"
    $ndkPath = "$sdkPath\ndk\29.0.14206865"
    
    if (-not (Test-Path $ndkPath)) {
        Write-Output "NDK not found at expected path: $ndkPath"
        Write-Output "Please check your NDK installation in Android Studio SDK Manager"
    } else {
        Write-Output "Found NDK at: $ndkPath"
        
        # Build for each Android architecture
        $androidArchs = @(
            @{ Name = "arm64-v8a"; Target = "aarch64-linux-android"; Linker = "aarch64-linux-android33-clang.exe" },
            @{ Name = "armeabi-v7a"; Target = "armv7-linux-androideabi"; Linker = "armv7a-linux-androideabi33-clang.exe" },
            @{ Name = "x86_64"; Target = "x86_64-linux-android"; Linker = "x86_64-linux-android33-clang.exe" },
            @{ Name = "x86"; Target = "i686-linux-android"; Linker = "i686-linux-android33-clang.exe" }
        )
        
        Push-Location -Path "$PSScriptRoot/loro-ffi"
        
        # Set up cargo config for Android
        $cargoConfigDir = ".cargo"
        New-Item -ItemType Directory -Path $cargoConfigDir -Force | Out-Null
        
        # Create cargo config content using here-string with proper path escaping
        $ndkPathForToml = $ndkPath -replace '\\', '/'  # 将反斜杠替换为正斜杠
        
        $cargoConfigContent = @"
[target.aarch64-linux-android]
linker = "$ndkPathForToml/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android29-clang.cmd"

[target.armv7-linux-androideabi]
linker = "$ndkPathForToml/toolchains/llvm/prebuilt/windows-x86_64/bin/armv7a-linux-androideabi29-clang.cmd"

[target.x86_64-linux-android]
linker = "$ndkPathForToml/toolchains/llvm/prebuilt/windows-x86_64/bin/x86_64-linux-android29-clang.cmd"

[target.i686-linux-android]
linker = "$ndkPathForToml/toolchains/llvm/prebuilt/windows-x86_64/bin/i686-linux-android29-clang.cmd"
"@
        
        Set-Content -Path "$cargoConfigDir/config.toml" -Value $cargoConfigContent
        Write-Output "Created cargo config with NDK linker settings"
        
        foreach ($arch in $androidArchs) {
            Write-Output "`nBuilding for Android $($arch.Name)..."
            
            # Always try to install the target to ensure it's available
            Write-Output "Installing or updating $($arch.Target)..."
            Start-Process -FilePath "rustup" -ArgumentList "target add $($arch.Target)" -NoNewWindow -Wait -RedirectStandardOutput "rustup_output.txt" -RedirectStandardError "rustup_error.txt"
            Get-Content "rustup_output.txt" | Write-Output
            Get-Content "rustup_error.txt" | Write-Output
            Remove-Item "rustup_output.txt", "rustup_error.txt" -Force -ErrorAction SilentlyContinue
            
            # Build the library
            Write-Output "Building with: cargo build --release --target $($arch.Target)"
            Start-Process -FilePath "cargo" -ArgumentList "build --release --target $($arch.Target)" -NoNewWindow -Wait -RedirectStandardOutput "cargo_output.txt" -RedirectStandardError "cargo_error.txt"
            Get-Content "cargo_output.txt" | Write-Output
            Get-Content "cargo_error.txt" | Write-Output
            Remove-Item "cargo_output.txt", "cargo_error.txt" -Force -ErrorAction SilentlyContinue
            
            # Check build result
            $androidLibPath = "target/$($arch.Target)/release/libloro_ffi.so"
            if (Test-Path $androidLibPath) {
                Copy-Item -Path $androidLibPath -Destination "$PSScriptRoot/release/android/$($arch.Name)/libloro_ffi.so" -Force
                Write-Output "Android $($arch.Name) build completed!"
                Write-Output "   Copied to: $PSScriptRoot/release/android/$($arch.Name)/libloro_ffi.so"
            } else {
                Write-Output "Android $($arch.Name) build failed, .so file not found"
                Write-Output "   Expected path: $androidLibPath"
            }
        }
        
        # Return to original directory
        Pop-Location
        
        # Clean up temporary cargo config
        Remove-Item -Path "$PSScriptRoot/loro-ffi/.cargo/config.toml" -Force
    }
}
