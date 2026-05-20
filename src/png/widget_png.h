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

// Image上下文结构
typedef struct {
    int width;        // 图片宽度
    int height;       // 图片高度
    int current_row;  // 当前已写入的行
    void* file_ptr;   // 文件指针
    void* image_ptr;  // 结构指针
    void* info_ptr;   // 错误处理指针
} ImageContext;

// PNG 专用函数
FFI_PLUGIN_EXPORT ImageContext* create_png_context(const char* file_path, int width, int height);
FFI_PLUGIN_EXPORT int write_png_data(ImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count);
FFI_PLUGIN_EXPORT int save_png_image(ImageContext* ctx);