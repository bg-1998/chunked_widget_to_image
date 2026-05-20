
cmake_minimum_required(VERSION 3.14)

project(chunked_widget_to_image_library VERSION 0.0.1 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(USE_FULL_DEPENDENCIES "Build with libjpeg-turbo, libpng, libyuv, zlib" ON)

if(USE_FULL_DEPENDENCIES)
    message(STATUS "Building with FULL DEPENDENCIES")

    set(THIRD_PARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party")

    if(NOT EXISTS "${THIRD_PARTY_DIR}/libpng" OR 
       NOT EXISTS "${THIRD_PARTY_DIR}/libjpeg-turbo" OR 
       NOT EXISTS "${THIRD_PARTY_DIR}/libyuv")
        message(FATAL_ERROR
            "Third-party libraries not found!\n"
            "Please run: bash ${CMAKE_CURRENT_SOURCE_DIR}/download_deps.sh"
        )
    endif()

    # ============================================
    # zlib
    # ============================================
    if(WIN32)
        message(STATUS "zlib: building from source (Windows)")
        set(ZLIB_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
        set(ZLIB_BUILD_TESTS OFF CACHE BOOL "" FORCE)
        add_subdirectory("${THIRD_PARTY_DIR}/zlib" "${CMAKE_CURRENT_BINARY_DIR}/zlib")
        set(ZLIB_TARGET zlibstatic)
    else()
        message(STATUS "zlib: using system library")
        find_library(ZLIB_LIBRARY z)
        if(NOT ZLIB_LIBRARY)
            message(FATAL_ERROR "System zlib (libz) not found!")
        endif()
        add_library(zlibstatic INTERFACE)
        target_link_libraries(zlibstatic INTERFACE ${ZLIB_LIBRARY})
        set(ZLIB_TARGET zlibstatic)
    endif()

    # ============================================
    # libpng
    # ============================================
    message(STATUS "libpng: building from source")
    set(PNG_DIR "${THIRD_PARTY_DIR}/libpng")
    
    set(PNG_SHARED OFF CACHE BOOL "" FORCE)
    set(PNG_STATIC ON CACHE BOOL "" FORCE)
    set(PNG_TESTS OFF CACHE BOOL "" FORCE)
    set(PNG_TOOLS OFF CACHE BOOL "" FORCE)
    
    # For OHOS and cross-compilation, use pre-generated config and skip try_run
    if(OHOS)
        set(PNG_PREFIX "" CACHE STRING "" FORCE)
        # Skip the configuration generation step that requires try_run
        set(SKIP_INSTALL_EXPORT TRUE CACHE BOOL "" FORCE)
        
        # Copy pre-generated pnglibconf.h to build directory
        file(COPY "${PNG_DIR}/pnglibconf.h" 
             DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/libpng/")
    endif()
    
    add_subdirectory("${PNG_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/libpng")
    set(PNG_TARGET png_static)

    # ============================================
    # libjpeg-turbo (8-bit only, no SIMD)
    # ============================================
    message(STATUS "libjpeg-turbo: building from source (8-bit only)")
    set(TJ_DIR "${THIRD_PARTY_DIR}/libjpeg-turbo")

    set(JPEG_HEADERS
        ${TJ_DIR}/jpeglib.h
        ${TJ_DIR}/jerror.h
        ${TJ_DIR}/jmorecfg.h
        ${TJ_DIR}/turbojpeg.h
        ${TJ_DIR}/src/jpegint.h
        ${TJ_DIR}/src/jsamplecomp.h
        ${TJ_DIR}/src/jdct.h
        ${TJ_DIR}/src/jinclude.h
        ${TJ_DIR}/src/jmemsys.h
    )

    set(JPEG_SOURCES
        ${TJ_DIR}/src/jcapimin.c
        ${TJ_DIR}/src/jcapistd.c
        ${TJ_DIR}/src/jccoefct.c
        ${TJ_DIR}/src/jccolor.c
        ${TJ_DIR}/src/jcdctmgr.c
        ${TJ_DIR}/src/jchuff.c
        ${TJ_DIR}/src/jcinit.c
        ${TJ_DIR}/src/jcmainct.c
        ${TJ_DIR}/src/jcmarker.c
        ${TJ_DIR}/src/jcmaster.c
        ${TJ_DIR}/src/jcomapi.c
        ${TJ_DIR}/src/jcparam.c
        ${TJ_DIR}/src/jcprepct.c
        ${TJ_DIR}/src/jcsample.c
        ${TJ_DIR}/src/jctrans.c
        ${TJ_DIR}/src/jdapimin.c
        ${TJ_DIR}/src/jdapistd.c
        ${TJ_DIR}/src/jdatadst.c
        ${TJ_DIR}/src/jdatasrc.c
        ${TJ_DIR}/src/jdcoefct.c
        ${TJ_DIR}/src/jdcolor.c
        ${TJ_DIR}/src/jddctmgr.c
        ${TJ_DIR}/src/jdhuff.c
        ${TJ_DIR}/src/jdinput.c
        ${TJ_DIR}/src/jdmainct.c
        ${TJ_DIR}/src/jdmarker.c
        ${TJ_DIR}/src/jdmaster.c
        ${TJ_DIR}/src/jdmerge.c
        ${TJ_DIR}/src/jdpostct.c
        ${TJ_DIR}/src/jdsample.c
        ${TJ_DIR}/src/jdtrans.c
        ${TJ_DIR}/src/jerror.c
        ${TJ_DIR}/src/jfdctflt.c
        ${TJ_DIR}/src/jfdctfst.c
        ${TJ_DIR}/src/jfdctint.c
        ${TJ_DIR}/src/jidctflt.c
        ${TJ_DIR}/src/jidctfst.c
        ${TJ_DIR}/src/jidctint.c
        ${TJ_DIR}/src/jidctred.c
        ${TJ_DIR}/src/jmemmgr.c
        ${TJ_DIR}/src/jmemnobs.c
        ${TJ_DIR}/src/jquant1.c
        ${TJ_DIR}/src/jquant2.c
        ${TJ_DIR}/src/jutils.c
        ${TJ_DIR}/src/turbojpeg.c
        ${TJ_DIR}/src/jpeg_nbits.c
        ${TJ_DIR}/src/jaricom.c
        ${TJ_DIR}/src/jstdhuff.c
    )

    set(JPEG_INCLUDE_DIR ${TJ_DIR})

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/jconfig.h "
#define HAVE_PROTOTYPES 1
#define HAVE_UNSIGNED_CHAR 1
#define HAVE_UNSIGNED_SHORT 1
#define HAVE_STDDEF_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_MEMCPY 1
#define HAVE_BSD_STRINGS 0
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_FCNTL_H 1
#define NEED_BSD_STRINGS 0
#define NEED_SYS_TYPES_H 0
#define NEED_FAR_POINTERS 0
#define NEED_SHORT_EXTERNAL_NAMES 0
#define INCOMPLETE_TYPES_BROKEN 0
#define BITS_IN_JSAMPLE 8
#define JPEG_LIB_VERSION 90
#define LIBJPEG_TURBO_VERSION 21000
#define JPEG_CJPEG_DJPEG
#define JPEG_INTERNAL_OPTIONS
#define DEFAULT_MAX_MEM 0
#define NO_MKTEMP 0
#define USE_SETMODE 0
#define DONT_USE_B_MODE 0
#define USE_FSEEKO 1
#define WITH_12BIT 0
#define C_LOSSLESS_SUPPORTED 0
#define D_LOSSLESS_SUPPORTED 0
#define ENTROPY_OPT_SUPPORTED 1
#define C_PROGRESSIVE_SUPPORTED 0
#define D_PROGRESSIVE_SUPPORTED 0
")

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/jconfigint.h "
#define PACKAGE \"libjpeg-turbo\"
#define VERSION \"2.1.0\"
#define BUILD \"\"
#define ARCH \"arm64\"
")

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/jversion.h "
#define JVERSION \"libjpeg-turbo version 2.1.0\"
#define JCOPYRIGHT \"Copyright (C) 2022, D. R. Commander\"
#define JLIB_VERSION 2010
")

    add_library(turbojpeg-static STATIC ${JPEG_SOURCES})
    target_include_directories(turbojpeg-static PRIVATE
        ${JPEG_INCLUDE_DIR}
        ${TJ_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
    )
    target_compile_definitions(turbojpeg-static PRIVATE
        BITS_IN_JSAMPLE=8
        NO_SIMD=1
        HAVE_JCONFIG_H=1
    )
    set(TJ_TARGET turbojpeg-static)

    # ============================================
    # libyuv
    # ============================================
    message(STATUS "libyuv: building from source")
    set(YUV_DIR "${THIRD_PARTY_DIR}/libyuv")

    file(GLOB_RECURSE YUV_ALL_SOURCES
        "${YUV_DIR}/source/*.cc"
        "${YUV_DIR}/source/*.c"
    )

    list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "sve.*\\.cc$")
    list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "lsx.*\\.cc$")
    list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "rvv.*\\.cc$")
    list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "sme.*\\.cc$")
    list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "mjpeg_decoder\\.cc$")
    list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "convert_jpeg\\.cc$")

    if(ANDROID_ABI STREQUAL "arm64-v8a")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "row_neon\\.cc$")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "compare_neon\\.cc$")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "rotate_neon\\.cc$")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "scale_neon\\.cc$")
    elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "neon64\\.cc$")
    elseif(OHOS OR APPLE)
        # For HarmonyOS, iOS and macOS, disable all NEON optimizations to avoid instruction compatibility issues
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "_neon\\.cc$")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "neon\\.cc$")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "neon64\\.cc$")
    else()
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "_neon\\.cc$")
        list(FILTER YUV_ALL_SOURCES EXCLUDE REGEX "neon\\.cc$")
    endif()

    add_library(yuv STATIC ${YUV_ALL_SOURCES})
    target_include_directories(yuv PUBLIC "${YUV_DIR}/include")
    target_compile_definitions(yuv PRIVATE LIBYUV_DISABLE_SVE=1)
    
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        target_compile_options(yuv PRIVATE -march=armv8.2-a+dotprod+i8mm)
    elseif(OHOS OR APPLE)
        # Disable NEON for HarmonyOS, iOS and macOS to avoid instruction compatibility issues
        target_compile_definitions(yuv PRIVATE LIBYUV_DISABLE_NEON=1)
    endif()

    # ============================================
    # Build main library
    # ============================================
    add_library(chunked_widget_to_image SHARED
        chunked_widget_to_image_full.c
        common/widget_to_image_common.c
        jpeg/widget_jpeg.c
        png/widget_png.c
        yuv/libyuv_bridge.cc
    )

    target_include_directories(chunked_widget_to_image PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/common
        ${CMAKE_CURRENT_SOURCE_DIR}/jpeg
        ${CMAKE_CURRENT_SOURCE_DIR}/png
        ${CMAKE_CURRENT_SOURCE_DIR}/yuv
        ${YUV_DIR}/include
        ${JPEG_INCLUDE_DIR}
        ${TJ_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
        ${PNG_DIR}
    )

    target_link_libraries(chunked_widget_to_image PRIVATE
        ${TJ_TARGET}
        ${PNG_TARGET}
        yuv
        ${ZLIB_TARGET}
    )

    target_compile_definitions(chunked_widget_to_image PRIVATE 
        USE_FULL_DEPENDENCIES
        BITS_IN_JSAMPLE=8
    )

else()
    message(STATUS "Building with SIMPLIFIED implementation")
    add_library(chunked_widget_to_image SHARED
        chunked_widget_to_image.c
    )
endif()

# ============================================
# Platform-specific configuration
# ============================================
if(IOS OR APPLE)
    # Build as Framework for iOS and macOS
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FRAMEWORK_INSTALL_DIR ${CMAKE_BINARY_DIR}/chunked_widget_to_image.framework)
    set_target_properties(chunked_widget_to_image PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        PUBLIC_HEADER chunked_widget_to_image.h
        MACOSX_FRAMEWORK_IDENTIFIER com.bg.chunked-widget-to-image
    )
else()
    set_target_properties(chunked_widget_to_image PROPERTIES
        PUBLIC_HEADER chunked_widget_to_image.h
        OUTPUT_NAME "chunked_widget_to_image"
    )
endif()

target_compile_definitions(chunked_widget_to_image PUBLIC DART_SHARED_LIB)

if(ANDROID OR OHOS)
    target_link_options(chunked_widget_to_image PRIVATE "-Wl,-z,max-page-size=16384")
endif()