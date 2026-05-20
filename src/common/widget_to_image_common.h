#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

// 将字节数据加载到内存并返回指针
FFI_PLUGIN_EXPORT uint8_t* load_bytes_to_memory(const uint8_t* bytes, size_t size);