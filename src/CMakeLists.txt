# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.22.1)

project(chunked_widget_to_image_library VERSION 0.0.1 LANGUAGES C CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置默认构建类型
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# 引入 ExternalProject 模块（关键：用于构建 libjpeg-turbo）
include(ExternalProject)
include(CMakeParseArguments)

# 定义可选编译选项，默认启用所有库
option(WITH_PNG "Enable PNG support" ON)
option(WITH_JPEG "Enable JPEG support" ON)

# --------------------------------------------------------------------------------

# Include libpng library
if(WITH_PNG)
  set(LIBPNG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps/libpng-1.6.43)

  # Handle pnglibconf.h - use prebuilt version
  configure_file(${LIBPNG_SOURCE_DIR}/scripts/pnglibconf.h.prebuilt
                 ${LIBPNG_SOURCE_DIR}/pnglibconf.h)

  add_subdirectory(${LIBPNG_SOURCE_DIR} libpng)
endif()

# --------------------------------------------------------------------------------

# Include libyuv library
set(LIBYUV_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps/libyuv)

if(IOS)
  # For iOS, we need to configure libyuv to not link against system JPEG library
  set(JPEG_LIBRARY "" CACHE STRING "Path to JPEG library" FORCE)
  set(JPEG_INCLUDE_DIR "" CACHE STRING "Path to JPEG headers" FORCE)
  set(JPEG_FOUND FALSE CACHE BOOL "JPEG library found" FORCE)
endif()

add_subdirectory(${LIBYUV_SOURCE_DIR} libyuv)

# --------------------------------------------------------------------------------

# Include libjpeg-turbo library
if(WITH_JPEG)
  # 定义 libjpeg-turbo 相关路径
  set(LIBJPEG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps/libjpeg-turbo-3.1.2)
  set(LIBJPEG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo-build-${ANDROID_ABI})
  set(LIBJPEG_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo-install-${ANDROID_ABI})

  # 针对不同平台设置不同的构建和安装目录
  if(IOS)
    set(LIBJPEG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo-build-ios)
    set(LIBJPEG_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo-install-ios)
  elseif(APPLE AND NOT IOS)
    set(LIBJPEG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo-build-macos)
    set(LIBJPEG_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo-install-macos)
  endif()

  set(LIBJPEG_CMAKE_ARGS
          -DCMAKE_INSTALL_PREFIX=${LIBJPEG_INSTALL_DIR}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -DENABLE_STATIC=ON
          -DENABLE_SHARED=OFF
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON
          -DWITH_JPEG8=ON  # 兼容 jpeg8 接口，避免编译报错
  )

  # Android 环境下添加 NDK/ABI 相关参数
  if(ANDROID)
    list(APPEND LIBJPEG_CMAKE_ARGS
            -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
            -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
            -DCMAKE_SYSTEM_NAME=Android
            -DCMAKE_SYSTEM_VERSION=${ANDROID_PLATFORM_LEVEL}
            -DANDROID_PLATFORM=${ANDROID_PLATFORM}
            -DANDROID_ABI=${ANDROID_ABI}
            -DANDROID_NDK=${ANDROID_NDK}
            -DCMAKE_ANDROID_NDK=${ANDROID_NDK}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
            -DANDROID_ARM_MODE=arm
            -DANDROID_STL=c++_static  # 适配 Android STL
    )
  # iOS 环境下添加相关参数
  elseif(IOS)
    # 设置默认的iOS部署目标版本
    if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
      set(CMAKE_OSX_DEPLOYMENT_TARGET 12.0)
    endif()
    
    # 获取 iOS SDK 路径
    execute_process(
      COMMAND xcrun --sdk iphoneos --show-sdk-path
      OUTPUT_VARIABLE IOS_SDK_PATH
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    list(APPEND LIBJPEG_CMAKE_ARGS
            -DCMAKE_SYSTEM_NAME=iOS
            -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
            -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
            -DCMAKE_OSX_SYSROOT=${IOS_SDK_PATH}
            -DCMAKE_SYSTEM_PROCESSOR=arm64
    )
    
    # 添加iOS特定的编译标志
    if(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
      list(APPEND LIBJPEG_CMAKE_ARGS 
              -DCMAKE_C_FLAGS=-fembed-bitcode
              -DCMAKE_CXX_FLAGS=-fembed-bitcode)
    endif()
    
  # macOS 环境下添加相关参数
  elseif(APPLE)
    # 设置默认的macOS部署目标版本
    if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
      set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)
    endif()
    
    list(APPEND LIBJPEG_CMAKE_ARGS
            -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
    )
  endif()

  # 使用 ExternalProject_Add 构建 libjpeg-turbo
  ExternalProject_Add(
          libjpeg-turbo
          SOURCE_DIR ${LIBJPEG_SOURCE_DIR}
          BINARY_DIR ${LIBJPEG_BUILD_DIR}
          INSTALL_DIR ${LIBJPEG_INSTALL_DIR}
          CMAKE_ARGS ${LIBJPEG_CMAKE_ARGS}
          BUILD_BYPRODUCTS
          ${LIBJPEG_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
          LOG_CONFIGURE ON  # 输出配置日志，方便调试
          LOG_BUILD ON      # 输出构建日志
          LOG_INSTALL ON    # 输出安装日志
  )
  # 创建导入库目标（让 CMake 识别 turbojpeg-static）
  add_library(turbojpeg-static STATIC IMPORTED GLOBAL)
  add_dependencies(turbojpeg-static libjpeg-turbo)  # 确保先构建 libjpeg-turbo
  # 设置导入库属性（分阶段：配置阶段用源码头文件，构建阶段用安装后的库）
  set_target_properties(turbojpeg-static PROPERTIES
          # 配置阶段：头文件指向源码目录（确保 CMake 配置不报错）
          INTERFACE_INCLUDE_DIRECTORIES "${LIBJPEG_SOURCE_DIR}/src"
          # 构建阶段：库文件路径（延迟检查）
          IMPORTED_LOCATION ${LIBJPEG_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
  )
endif()

# --------------------------------------------------------------------------------

set(PLUGIN_SOURCES
  "chunked_widget_to_image.c"
  "libyuv_bridge.cpp"
)

# Conditionally add sources based on enabled features
if(WITH_PNG)
  list(APPEND PLUGIN_SOURCES "widget_png.c")
endif()

if(WITH_JPEG)
  list(APPEND PLUGIN_SOURCES "widget_jpeg.c")
endif()

add_library(chunked_widget_to_image SHARED
  ${PLUGIN_SOURCES}
)

if(IOS OR APPLE)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FRAMEWORK_INSTALL_DIR ${CMAKE_BINARY_DIR}/chunked_widget_to_image.framework)
  set_target_properties(chunked_widget_to_image PROPERTIES
          FRAMEWORK TRUE
          FRAMEWORK_VERSION A
          PUBLIC_HEADER chunked_widget_to_image.h
          MACOSX_FRAMEWORK_IDENTIFIER com.bg1998.chunked_widget_to_image
  )
  install(TARGETS chunked_widget_to_image FRAMEWORK DESTINATION .)
else()
set_target_properties(chunked_widget_to_image PROPERTIES
  PUBLIC_HEADER chunked_widget_to_image.h
  OUTPUT_NAME "chunked_widget_to_image"
)
endif()

target_compile_definitions(chunked_widget_to_image PUBLIC DART_SHARED_LIB)

# Add conditional compile definitions
if(WITH_PNG)
  target_compile_definitions(chunked_widget_to_image PRIVATE WITH_PNG)
endif()

if(WITH_JPEG)
  target_compile_definitions(chunked_widget_to_image PRIVATE WITH_JPEG)
endif()

# Add include directories
target_include_directories(chunked_widget_to_image PRIVATE
        ${LIBYUV_SOURCE_DIR}/include
)

# Conditionally add include directories based on enabled features
if(WITH_PNG)
  target_include_directories(chunked_widget_to_image PRIVATE
          ${LIBPNG_SOURCE_DIR}
  )
endif()

if(WITH_JPEG)
  target_include_directories(chunked_widget_to_image PRIVATE
          ${LIBJPEG_SOURCE_DIR}/src
          ${LIBJPEG_INSTALL_DIR}/include
  )
endif()

# 链接库（确保先构建 libjpeg-turbo）
if(WITH_JPEG)
  add_dependencies(chunked_widget_to_image libjpeg-turbo)
endif()

# Conditionally link libraries based on enabled features
set(PLUGIN_LIBRARIES yuv)
if(WITH_PNG)
  list(APPEND PLUGIN_LIBRARIES png_static)
endif()

if(WITH_JPEG)
  list(APPEND PLUGIN_LIBRARIES turbojpeg-static)
endif()

target_link_libraries(chunked_widget_to_image PRIVATE
        ${PLUGIN_LIBRARIES}
)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(chunked_widget_to_image PRIVATE "-Wl,-z,max-page-size=16384")
endif()