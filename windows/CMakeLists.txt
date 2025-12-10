# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This is a simplified CMakeLists.txt that only bundles the DLL file
# The actual FFI calls are handled directly in Dart code (lib/src/bindings.dart)

# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "loro_ffi")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

# Create a dummy source file for the plugin
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp" "")

# Create a library with the dummy source file to satisfy Flutter's plugin requirements
add_library(${PLUGIN_NAME} SHARED
  "${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp"
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt.
apply_standard_settings(${PLUGIN_NAME})

# Set properties for the dummy library
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Link against Flutter libraries
 target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This ensures the Rust DLL is included in the final build.
set(loro_ffi_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/../loro_ffi.dll"
  PARENT_SCOPE
)
