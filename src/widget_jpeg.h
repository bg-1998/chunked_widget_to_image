#ifndef WIDGET_JPEG_H
#define WIDGET_JPEG_H

#include "chunked_widget_to_image.h"

#ifdef WITH_JPEG
#include <jpeglib.h>

// JPEG 编码相关函数声明
ChunkedWidgetToImageContext* create_jpeg_context(const char* file_path, int width, int height);
int write_jpeg_data(ChunkedWidgetToImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count);
int save_jpeg_image(ChunkedWidgetToImageContext* ctx);

#endif // WITH_JPEG
#endif // WIDGET_JPEG_H