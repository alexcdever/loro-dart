cmake_minimum_required(VERSION 3.14)

project(loro_dart LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 标准的 Flutter Windows 插件配置
# 获取项目根目录
set(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")

# Flutter 目录结构
set(FLUTTER_EMBEDDER_DIR "${PROJECT_ROOT}/flutter")
set(FLUTTER_PLUGIN_DIR "${PROJECT_ROOT}")
set(FLUTTER_PLUGIN_NAME "loro_dart")

# 添加 flutter 目录到包含路径
include_directories("${FLUTTER_EMBEDDER_DIR}")

# 查找并包含 Flutter 生成的配置文件
file(GLOB FLUTTER_GENERATED_FILES
  "${FLUTTER_EMBEDDER_DIR}/generated_plugin_registrant.cc"
  "${FLUTTER_EMBEDDER_DIR}/generated_plugin_registrant.h"
  "${FLUTTER_EMBEDDER_DIR}/generated_plugins.cmake"
)

# 如果找到生成的插件文件，包含它们
if(EXISTS "${FLUTTER_EMBEDDER_DIR}/generated_plugins.cmake")
  include("${FLUTTER_EMBEDDER_DIR}/generated_plugins.cmake")
endif()

# 定义插件目标
add_library(${FLUTTER_PLUGIN_NAME} SHARED
  "${CMAKE_CURRENT_SOURCE_DIR}/loro_dart_plugin.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/loro_dart_plugin.h"
)

# 设置插件属性
set_target_properties(${FLUTTER_PLUGIN_NAME} PROPERTIES
  PREFIX ""
  OUTPUT_NAME "${FLUTTER_PLUGIN_NAME}"
  SUFFIX ".dll"
  CXX_VISIBILITY_PRESET hidden
  DEFINE_SYMBOL "${FLUTTER_PLUGIN_NAME}_BUILDING_DLL"
)

# 链接 Flutter 库 - 使用 Flutter 提供的标准库链接方式
# 注意：在实际构建环境中，Flutter 引擎库会由 Flutter 构建系统自动提供
# 这里只配置基本的插件结构

# 复制动态库到输出目录
add_custom_command(
  TARGET ${FLUTTER_PLUGIN_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  "${CMAKE_CURRENT_SOURCE_DIR}/loro_dart.dll"
  "$<TARGET_FILE_DIR:${FLUTTER_PLUGIN_NAME}>/${FLUTTER_PLUGIN_NAME}.dll"
  COMMENT "Copying dynamic library to output directory"
)

# 安装配置
install(TARGETS ${FLUTTER_PLUGIN_NAME}
  RUNTIME DESTINATION "bin"
  LIBRARY DESTINATION "lib"
  ARCHIVE DESTINATION "lib"
)

# 配置生成的绑定文件
file(GLOB BINDING_FILES
  "${PROJECT_ROOT}/lib/src/frb_generated.dart"
  "${PROJECT_ROOT}/lib/src/frb_generated.io.dart"
  "${PROJECT_ROOT}/lib/src/frb_generated.web.dart"
)

# 添加绑定文件作为依赖
add_custom_target(bindings ALL DEPENDS ${BINDING_FILES})
