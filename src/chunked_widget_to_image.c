#include "chunked_widget_to_image.h"
#include "widget_png.h"
#include "widget_jpeg.h"
#include "libyuv.h"

void rgba_to_i420(const uint8_t* sample,int sample_size,
                  uint8_t* dst_y,int dst_stride_y,
                  uint8_t* dst_u,int dst_stride_u,
                  uint8_t* dst_v,int dst_stride_v,
                  int src_width,int src_height);

/* ================= 创建图像编码上下文 ================= */
FFI_PLUGIN_EXPORT ChunkedWidgetToImageContext* create_chunked_widget_to_image(const char* file_path, int width, int height,int format) {
    if (!file_path || width <= 0 || height <= 0) {
        return NULL;
    }

    /* ================= PNG ================= */
    if (format == 0) {
#ifdef WITH_PNG
        return create_png_context(file_path, width, height);
#else
        return NULL;
#endif
    }
    /* ================= JPEG ================= */
    else if (format == 1) {
#ifdef WITH_JPEG
        return create_jpeg_context(file_path, width, height);
#else
        return NULL;
#endif
    }
    /* ================= WEBP ================= */
    else if(format == 2){
        // WebP support not implemented yet
        ChunkedWidgetToImageContext* ctx = (ChunkedWidgetToImageContext*)calloc(1, sizeof(ChunkedWidgetToImageContext));
        if (ctx) {
            ctx->format = format;
            ctx->width = width;
            ctx->height = height;
            ctx->current_row = 0;
        }
        return ctx;
    }

    return NULL;
}

/* ================= 分块写入 RGBA 行 ================= */
FFI_PLUGIN_EXPORT int write_chunked_widget_to_image(
        ChunkedWidgetToImageContext *ctx,
        uint8_t* rgba_data,
        int src_stride,
        int row_count
) {
    if (!ctx || !rgba_data || row_count <= 0 ||
        ctx->current_row + row_count > ctx->height) {
        return 1;
    }

    int ret = 0;

    /* -------- PNG -------- */
    if (ctx->format == 0) {
#ifdef WITH_PNG
        ret = write_png_data(ctx, rgba_data, src_stride, row_count);
        // Only free rgba_data if write was successful
        if (ret == 0) {
            free(rgba_data);
        }
        return ret;
#else
        free(rgba_data);
        return -1; // PNG support not compiled in
#endif
    }
    /* -------- JPEG -------- */
    else if(ctx->format == 1){
#ifdef WITH_JPEG
        ret = write_jpeg_data(ctx, rgba_data, src_stride, row_count);
        // Only free rgba_data if write was successful
        if (ret == 0) {
            free(rgba_data);
        }
        return ret;
#else
        free(rgba_data);
        return -1; // JPEG support not compiled in
#endif
    }
    /* -------- WEBP -------- */
    else if(ctx->format == 2){
        // WebP support not implemented yet
        ret = -6; // 不支持的格式
        free(rgba_data);
        return ret;
    }

    free(rgba_data);
    return -1; // Unknown format
}

/* ================= 完成并释放 ================= */
FFI_PLUGIN_EXPORT int save_chunked_widget_to_image(ChunkedWidgetToImageContext *ctx) {
    if (!ctx) return -1;

    int ret = 0;

    /* -------- PNG -------- */
    if (ctx->format == 0) {
#ifdef WITH_PNG
        ret = save_png_image(ctx);
#else
        ret = -1; // PNG support not compiled in
#endif
    }
    /* -------- JPEG -------- */
    else if (ctx->format == 1) {
#ifdef WITH_JPEG
        ret = save_jpeg_image(ctx);
#else
        ret = -1; // JPEG support not compiled in
#endif
    }
    /* -------- WEBP -------- */
    else if (ctx->format == 2) {
        // WebP support not implemented yet
        if (ctx->file_ptr) {
            fclose(ctx->file_ptr);
        }
        ret = 0;
    }

    free(ctx);
    return ret;
}

/* ================= 将字节数据加载到内存 ================= */
FFI_PLUGIN_EXPORT void* load_bytes_to_memory(const uint8_t* bytes, size_t size) {
    if (!bytes || size <= 0) {
        return NULL;
    }
    void* mem_ptr = malloc(size);
    if (!mem_ptr) {
        return NULL;
    }
    memcpy(mem_ptr, bytes, size);
    return mem_ptr;
}