#ifdef WITH_JPEG

#include "widget_jpeg.h"
#include "libyuv.h"
#include <setjmp.h>

/* ===== JPEG 错误处理 ===== */
typedef struct {
    struct jpeg_error_mgr pub;
    jmp_buf setjmp_buffer;
} my_error_mgr;

METHODDEF(void) my_error_exit(j_common_ptr cinfo){
    my_error_mgr *myerr = (my_error_mgr *) cinfo->err;
    (*cinfo->err->output_message)(cinfo);
    longjmp(myerr->setjmp_buffer, 1);
}

void rgba_to_i420(const uint8_t* sample,int sample_size,
                  uint8_t* dst_y,int dst_stride_y,
                  uint8_t* dst_u,int dst_stride_u,
                  uint8_t* dst_v,int dst_stride_v,
                  int src_width,int src_height);

ChunkedWidgetToImageContext* create_jpeg_context(const char* file_path, int width, int height) {
    ChunkedWidgetToImageContext* ctx = (ChunkedWidgetToImageContext*)calloc(1, sizeof(ChunkedWidgetToImageContext));
    if (!ctx) {
        return NULL;
    }

    FILE* fp = fopen(file_path, "wb");
    if (!fp) {
        free(ctx);
        return NULL;
    }

    struct jpeg_compress_struct *cinfo = (struct jpeg_compress_struct *) calloc(1, sizeof(*cinfo));
    my_error_mgr *jerr = (my_error_mgr *) calloc(1, sizeof(*jerr));
    if (!cinfo || !jerr) {
        free(cinfo);
        free(jerr);
        fclose(fp);
        free(ctx);
        return NULL;
    }
    
    cinfo->err = jpeg_std_error(&jerr->pub);
    jerr->pub.error_exit = my_error_exit;

    if (setjmp(jerr->setjmp_buffer)) {
        jpeg_destroy_compress(cinfo);
        free(cinfo);
        free(jerr);
        fclose(fp);
        free(ctx);
        return NULL;
    }

    jpeg_create_compress(cinfo);
    jpeg_stdio_dest(cinfo, fp);

    cinfo->image_width = width;
    cinfo->image_height = height;
    cinfo->input_components = 3;
    cinfo->in_color_space = JCS_YCbCr;// JPEG原生YUV格式（对应I420）

    jpeg_set_defaults(cinfo);
    jpeg_set_quality(cinfo, 100, TRUE);
    cinfo->dct_method = JDCT_FASTEST;
    jpeg_start_compress(cinfo, TRUE);

    ctx->format = 1; // JPEG format
    ctx->width = width;
    ctx->height = height;
    ctx->current_row = 0;
    ctx->image_ptr = cinfo;
    ctx->info_ptr = jerr;
    ctx->file_ptr = fp;
    
    return ctx;
}

int write_jpeg_data(ChunkedWidgetToImageContext* ctx, uint8_t* rgba_data, int src_stride, int row_count) {
    if (!ctx || !rgba_data || row_count <= 0 ||
        ctx->current_row + row_count > ctx->height) {
        return 1;
    }

    struct jpeg_compress_struct* cinfo = (struct jpeg_compress_struct*)ctx->image_ptr;
    int width = ctx->width;
    uint8_t* jpeg_row = (uint8_t*)malloc(width * 3);
    if (!jpeg_row) {
        return -2;
    }
    
    JSAMPROW row_ptr[1];
    row_ptr[0] = jpeg_row;
    
    // 分配 I420 缓冲区
    uint8_t* y_plane = malloc(width * row_count);
    uint8_t* u_plane = malloc((width / 2) * (row_count / 2));
    uint8_t* v_plane = malloc((width / 2) * (row_count / 2));
    if (!y_plane || !u_plane || !v_plane) {
        free(jpeg_row);
        free(y_plane);
        free(u_plane);
        free(v_plane);
        return -2;
    }
    
    // RGBA → I420 转换
    rgba_to_i420(
            rgba_data,
            src_stride,
            y_plane,
            width,
            u_plane,
            width / 2,
            v_plane,
            width / 2,
            width,
            row_count
    );

    for (int y = 0; y < row_count; y++) {
        uint8_t* y_row = y_plane + y * width;
        uint8_t* u_row = u_plane + (y / 2) * (width / 2);
        uint8_t* v_row = v_plane + (y / 2) * (width / 2);

        for (int x = 0; x < width; x++) {
            jpeg_row[x * 3 + 0] = y_row[x];
            jpeg_row[x * 3 + 1] = u_row[x >> 1];
            jpeg_row[x * 3 + 2] = v_row[x >> 1];
        }
        jpeg_write_scanlines(cinfo, row_ptr, 1);
        ctx->current_row++;
    }
    
    free(y_plane);
    free(u_plane);
    free(v_plane);
    free(jpeg_row);
    
    return 0;
}

int save_jpeg_image(ChunkedWidgetToImageContext* ctx) {
    if (!ctx) return -1;

    struct jpeg_compress_struct* cinfo = (struct jpeg_compress_struct*)ctx->image_ptr;
    my_error_mgr* jerr = (my_error_mgr*)ctx->info_ptr;
    
    jpeg_finish_compress(cinfo);
    jpeg_destroy_compress(cinfo);
    free(cinfo);
    free(jerr);

    if (ctx->file_ptr) {
        fclose(ctx->file_ptr);
    }
    
    return 0;
}

#endif // WITH_JPEG