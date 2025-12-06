@echo off
REM Windows platform build script
REM For building Loro FFI library in Windows environment

echo ===== Start building Loro FFI Windows library =====

REM Set directory paths
set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..
set RUST_DIR=%ROOT_DIR%\native\rust

REM Create output directories
if not exist "%ROOT_DIR%\windows" mkdir "%ROOT_DIR%\windows"
if not exist "%ROOT_DIR%\include" mkdir "%ROOT_DIR%\include"

echo ===== Generating C header file =====
cd "%RUST_DIR%"
cbindgen --config cbindgen.toml -o "%ROOT_DIR%\include\loro_ffi.h"

echo ===== Building Windows library =====
cd "%RUST_DIR%"
cargo build --release --target x86_64-pc-windows-msvc

REM Copy Windows library file
copy "%RUST_DIR%\target\x86_64-pc-windows-msvc\release\loro_ffi.dll" "%ROOT_DIR%\windows\loro_ffi_plugin.dll"

echo ===== Windows library build completed =====