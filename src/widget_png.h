#ifndef WIDGET_PNG_H
#define WIDGET_PNG_H

#include "chunked_widget_to_image.h"

#ifdef WITH_PNG
#include <png.h>

// PNG 编码相关函数声明
ChunkedWidgetToImageContext* create_png_context(const char* file_path, int width, int height);
int write_png_data(ChunkedWidgetToImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count);
int save_png_image(ChunkedWidgetToImageContext* ctx);

#endif // WITH_PNG
#endif // WIDGET_PNG_H