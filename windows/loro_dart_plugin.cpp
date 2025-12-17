#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <memory>
#include <sstream>

namespace loro_dart {

class LoroDartPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  LoroDartPlugin();

  virtual ~LoroDartPlugin();

  // Disallow copy and assign.
  LoroDartPlugin(const LoroDartPlugin&) = delete;
  LoroDartPlugin& operator=(const LoroDartPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void LoroDartPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "loro_dart",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<LoroDartPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

LoroDartPlugin::LoroDartPlugin() {}

LoroDartPlugin::~LoroDartPlugin() {}

void LoroDartPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  // Handle any platform-specific method calls here
  // For now, we just return a success response
  result->Success(flutter::EncodableValue());
}

}  // namespace loro_dart

void RegisterLoroDartPlugin(flutter::PluginRegistrarWindows* registrar) {
  loro_dart::LoroDartPlugin::RegisterWithRegistrar(registrar);
}
