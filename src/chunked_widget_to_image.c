#include "chunked_widget_to_image.h"

// ============================================
// load_bytes_to_memory
// ============================================
uint8_t* load_bytes_to_memory(const uint8_t* bytes, size_t size) {
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

// ============================================
// JPEG Functions (simplified)
// ============================================
ImageContext* create_jpeg_context(const char* file_path, int width, int height) {
    ImageContext* ctx = (ImageContext*)calloc(1, sizeof(ImageContext));
    if (!ctx) {
        return NULL;
    }
    FILE* fp = fopen(file_path, "wb");
    if (!fp) {
        free(ctx);
        return NULL;
    }
    ctx->width = width;
    ctx->height = height;
    ctx->current_row = 0;
    ctx->file_ptr = fp;
    ctx->image_ptr = NULL;
    ctx->info_ptr = NULL;
    return ctx;
}

int write_jpeg_data(ImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count) {
    if (!ctx || !rgba_data || row_count <= 0 ||
        ctx->current_row + row_count > ctx->height) {
        return 1;
    }
    ctx->current_row += row_count;
    return 0;
}

int save_jpeg_image(ImageContext* ctx) {
    if (!ctx) return -1;
    FILE *fp = (FILE*)ctx->file_ptr;
    if (fp) {
        fclose(fp);
    }
    free(ctx);
    return 0;
}

// ============================================
// PNG Functions (simplified)
// ============================================
ImageContext* create_png_context(const char* file_path, int width, int height) {
    ImageContext* ctx = (ImageContext*)calloc(1, sizeof(ImageContext));
    if (!ctx) {
        return NULL;
    }
    FILE* fp = fopen(file_path, "wb");
    if (!fp) {
        free(ctx);
        return NULL;
    }
    ctx->width = width;
    ctx->height = height;
    ctx->current_row = 0;
    ctx->file_ptr = fp;
    ctx->image_ptr = NULL;
    ctx->info_ptr = NULL;
    return ctx;
}

int write_png_data(ImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count) {
    if (!ctx || !rgba_data || row_count <= 0 ||
        ctx->current_row + row_count > ctx->height) {
        return 1;
    }
    ctx->current_row += row_count;
    return 0;
}

int save_png_image(ImageContext* ctx) {
    if (!ctx) return -1;
    FILE *fp = (FILE*)ctx->file_ptr;
    if (fp) {
        fclose(fp);
    }
    free(ctx);
    return 0;
}

// ============================================
// RGBA to I420 conversion
// ============================================
void rgba_to_i420(const uint8_t* sample, int sample_size,
                  uint8_t* dst_y, int dst_stride_y,
                  uint8_t* dst_u, int dst_stride_u,
                  uint8_t* dst_v, int dst_stride_v,
                  int src_width, int src_height) {
    if (sample && dst_y && dst_u && dst_v) {
        memset(dst_y, 0, dst_stride_y * src_height);
        memset(dst_u, 128, dst_stride_u * (src_height / 2));
        memset(dst_v, 128, dst_stride_v * (src_height / 2));
    }
}
