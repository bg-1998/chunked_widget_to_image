#ifdef WITH_PNG

#include "widget_png.h"
#include <setjmp.h>

/* ================= libpng 错误处理 ================= */
static void png_encoder_error_fn(png_structp png_ptr, png_const_charp msg) {
    fprintf(stderr, "PNG encoder error: %s\n", msg);
    longjmp(png_jmpbuf(png_ptr), 1);
}

static void png_encoder_warning_fn(png_structp png_ptr, png_const_charp msg) {
    fprintf(stderr, "PNG encoder warning: %s\n", msg);
}

ChunkedWidgetToImageContext* create_png_context(const char* file_path, int width, int height) {
    ChunkedWidgetToImageContext* ctx = (ChunkedWidgetToImageContext*)calloc(1, sizeof(ChunkedWidgetToImageContext));
    if (!ctx) {
        return NULL;
    }

    FILE* fp = fopen(file_path, "wb");
    if (!fp) {
        free(ctx);
        return NULL;
    }

    png_structp png_ptr = png_create_write_struct(
            PNG_LIBPNG_VER_STRING,
            NULL,
            png_encoder_error_fn,
            png_encoder_warning_fn
    );
    if (!png_ptr) {
        fclose(fp);
        free(ctx);
        return NULL;
    }
    
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr) {
        png_destroy_write_struct(&png_ptr, NULL);
        fclose(fp);
        free(ctx);
        return NULL;
    }

    if (setjmp(png_jmpbuf(png_ptr))) {
        png_destroy_write_struct(&png_ptr, &info_ptr);
        fclose(fp);
        free(ctx);
        return NULL;
    }
    
    png_init_io(png_ptr, fp);
    png_set_IHDR(
            png_ptr,
            info_ptr,
            width,
            height,
            8,
            PNG_COLOR_TYPE_RGBA,
            PNG_INTERLACE_NONE,
            PNG_COMPRESSION_TYPE_DEFAULT,
            PNG_FILTER_TYPE_DEFAULT
    );
    png_set_filter(png_ptr, 0, PNG_FILTER_NONE);
    png_set_compression_level(png_ptr, 1);
    png_write_info(png_ptr, info_ptr);
    
    ctx->format = 0; // PNG format
    ctx->width = width;
    ctx->height = height;
    ctx->current_row = 0;
    ctx->image_ptr = png_ptr;
    ctx->info_ptr = info_ptr;
    ctx->file_ptr = fp;
    
    return ctx;
}

int write_png_data(ChunkedWidgetToImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count) {
    if (!ctx || !rgba_data || row_count <= 0 ||
        ctx->current_row + row_count > ctx->height) {
        return 1;
    }

    png_structp png_ptr = (png_structp)ctx->image_ptr;
    const int MAX_BLOCK_WIDTH_PX = 5120*4; // 最大分块宽度（像素）
    
    if (setjmp(png_jmpbuf(png_ptr))) {
        return -2;
    }
    
    png_bytep row_buf = (png_bytep)malloc(src_stride);
    if (!row_buf) {
        return -2;
    }
    
    for (int row_idx = 0; row_idx < row_count; row_idx++) {
        memset(row_buf, 0, src_stride);
        // 当前行的原始 RGBA 数据起始地址（核心：确保指针计算正确）
        png_bytep curr_row_data = rgba_data + (row_idx * src_stride);
        // 3. 按 5120*4 像素宽度纵向切割当前行，逐块填充
        for (int block_x = 0; block_x < src_stride; block_x += MAX_BLOCK_WIDTH_PX) {
            // 计算当前块的实际宽度（像素）：最后一块可能不足 5120*4
            int curr_block_width_px = (block_x + MAX_BLOCK_WIDTH_PX) > src_stride
                                      ? (src_stride - block_x)
                                      : MAX_BLOCK_WIDTH_PX;
            memcpy(
                    row_buf + block_x,    // 目标：行缓冲区的块位置
                    curr_row_data + block_x, // 源：原始数据的块位置
                    curr_block_width_px            // 拷贝字节数
            );
        }
        png_write_rows(png_ptr, &row_buf, 1);
    }
    
    free(row_buf);
    ctx->current_row += row_count;
    return 0;
}

int save_png_image(ChunkedWidgetToImageContext* ctx) {
    if (!ctx) return -1;

    png_structp png_ptr = (png_structp)ctx->image_ptr;
    png_infop info_ptr = (png_infop)ctx->info_ptr;
    
    if (png_ptr && info_ptr) {
        if (!setjmp(png_jmpbuf(png_ptr))) {
            png_write_end(png_ptr, info_ptr);
        } else {
            return -2;
        }
        png_destroy_write_struct(&png_ptr, &info_ptr);
    }

    if (ctx->file_ptr) {
        fclose(ctx->file_ptr);
    }
    
    return 0;
}

#endif // WITH_PNG