Pod::Spec.new do |s|
  s.name             = 'LoroFFI'
  s.version          = '0.1.0'
  s.summary          = 'Loro FFI bindings'
  s.description      = <<-DESC
Flutter plugin for Loro FFI bindings, providing cross-platform support.
                       DESC
  s.homepage         = 'https://github.com/loro-dev/loro-dart'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Loro Team' => 'info@loro.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.vendored_libraries = 'Frameworks/libloro_ffi.a'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  
  # 确保静态库被正确链接
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-force_load $(PODS_ROOT)/LoroFFI/Frameworks/libloro_ffi.a',
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end