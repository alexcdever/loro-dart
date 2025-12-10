// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "../include/loro_ffi.h"

// A Flutter plugin that provides access to the Loro FFI library.
class LoroFfiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  virtual ~LoroFfiPlugin();

  // Creates a new plugin instance.
  explicit LoroFfiPlugin();
};

// static
void LoroFfiPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<LoroFfiPlugin>();
  registrar->AddPlugin(std::move(plugin));
}

LoroFfiPlugin::LoroFfiPlugin() {}

LoroFfiPlugin::~LoroFfiPlugin() {}


