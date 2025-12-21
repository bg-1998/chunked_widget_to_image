#ifndef CHUNKED_WIDGET_TO_IMAGE_H
#define CHUNKED_WIDGET_TO_IMAGE_H

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

typedef struct {
    int format; //0png 1jpeg 2webp
    int width;        // 图片宽度
    int height;       // 图片高度
    int current_row;  // 当前已写入的行
    FILE* file_ptr;   // 文件指针

    void* image_ptr;
    void* info_ptr;

} ChunkedWidgetToImageContext;

// 创建图像缓冲区
FFI_PLUGIN_EXPORT ChunkedWidgetToImageContext* create_chunked_widget_to_image(const char *path, int width, int height, int format);

// 写入图像数据
FFI_PLUGIN_EXPORT int write_chunked_widget_to_image(ChunkedWidgetToImageContext *ctx,uint8_t *rgba_data,int src_stride, int rows);

// 保存图像
FFI_PLUGIN_EXPORT int save_chunked_widget_to_image(ChunkedWidgetToImageContext *ctx);

// 将字节数据加载到内存并返回指针
FFI_PLUGIN_EXPORT void* load_bytes_to_memory(const uint8_t* bytes, size_t size);

#endif // CHUNKED_WIDGET_TO_IMAGE_H